from django.shortcuts import render, redirect, get_object_or_404
from django.contrib import messages
from django.contrib.auth import authenticate, login as auth_login, logout
from django.contrib.auth.decorators import login_required
from django.views.decorators.http import require_POST
from django.views.decorators.cache import never_cache
from functools import wraps
from django.db import transaction
from django.db.models import Count, Avg, Q
from home.models import Usuario, TipoUsuario, Profesor, Alumno, Administrador, Grupo, Palabra
from home.models import Carrera, Categoria, Alumno_Insignia, Alumno_Practica, Lista_Grupo, Grupo_Alumno
from home.models import Nivel, Dificultad, Dificultad_Juego, Insignia, Intento_Palabra, Lista, Lista_Palabra
from home.models import Proceso_Lista, Rango, Ranking, Reporte, TipoRanking, UsuarioManager, Juego, Practica_Sesion

# Create your views here.

def role_required(role):
    def decorator(view_func):
        @wraps(view_func)
        def wrapper(request, *args, **kwargs):
            if not request.user.is_authenticated:
                return redirect('login')
            
            tipo_usuario = request.user.tipo_usuario.nombre.strip().lower()
            
            if tipo_usuario != role:
                return redirect('login')
            
            return view_func(request, *args, **kwargs)
        
        return wrapper
    return decorator

def landing(request):
    return render(request, 'base/landing.html')

def login(request):
    if request.method == 'POST':
        correo = request.POST.get('email')
        password = request.POST.get('password')
        
        usuario = authenticate(
            request,
            correo=correo,
            password=password
        )
        
        if usuario is not None:
            auth_login(request, usuario)
            
            tipo_usuario = usuario.tipo_usuario.nombre.strip().lower()
            
            if tipo_usuario == 'teacher':
                return redirect('teacher_dashboard')
            
            elif tipo_usuario == 'student':
                return redirect('student_home')
            
            elif tipo_usuario == 'administrator':
                return redirect('admin_gen_panel')
            
        return render(
            request,
            'users/login.html',
            {
                'error': 'Incorrect email or password.'
            }
        )
    return render(request, 'users/login.html')

def choose_role(request):
    return render(request, 'base/choose_role.html')

def signup_student(request):
    return render(request, 'users/singup_student.html')

def signup_teacher(request):
    return render(request, 'users/singup_teacher.html')

@never_cache
@role_required('teacher')
def dashboard(request):
    profesor = request.user.profesor
    
    grupos = Grupo.objects.filter(profesor=profesor)
    
    total_groups = grupos.count()
    
    total_lists = Lista_Grupo.objects.filter(
        grupo__in=grupos
    ).values('lista').distinct().count()
    
    total_students = Grupo_Alumno.objects.filter(
        grupo__in=grupos
    ).values('alumno').distinct().count()
    
    students_by_level = Alumno.objects.filter(
            grupo_alumnos__grupo__in=grupos
        ).values(
            'nivel__codigo'
        ).annotate(
            total=Count('matricula')
        ).order_by('nivel__codigo')
    
    level_counts = {
        'A1': 0,
        'A2': 0,
        'B1': 0,
        'B2': 0,
        'C1': 0,
        'C2': 0,
    }
    
    for level in students_by_level:
        level_counts[level['nivel__codigo']] = level['total']
        
    level_percentages = {}
    
    for level, count in level_counts.items():
        if total_students > 0:
            level_percentages[level] = round(
                (count / total_students) * 100,
                1
            )
        else:
            level_percentages[level] = 0
            
    group_performance = []
    
    for grupo in grupos:
        average = Practica_Sesion.objects.filter(
            alumnos__alumno__grupo_alumnos__grupo=grupo
        ).aggregate(
            average=Avg('porcentaje_aciertos')
        )['average']
        
        group_performance.append({
            'nombre': grupo.nombre,
            'average': round(average, 1) if average is not None else 0
        })
        
    all_performance = Practica_Sesion.objects.filter(
        alumnos__alumno__grupo_alumnos__grupo__in=grupos
    ).aggregate(
        average=Avg('porcentaje_aciertos')
    )['average']
    
    average_score = round(
        all_performance, 1
    ) if all_performance is not None else 0
    
    challenging_words = (
        Intento_Palabra.objects
        .filter(
            practica_sesion__alumnos__alumno__grupo_alumnos__grupo__in=grupos
        )
        .values(
            'palabra__significado'
        )
        .annotate(
            total_attempts=Count('clave'),
            failed_attempts=Count(
                'clave',
                filter=Q(acertado=0)
            )
        )
    )
    
    challenging_words_data = []
    
    for word in challenging_words:
        miss_rate = (
            (word['failed_attempts'] / word['total_attempts']) * 100
        )
        
        challenging_words_data.append({
            'word': word['palabra__significado'],
            'miss_rate': round(miss_rate, 1)
        })
        
    challenging_words_data.sort(
        key=lambda x: x['miss_rate'],
        reverse=True
    )
    
    challenging_words_data = challenging_words_data[:5]
    
    return render(
        request, 
        'teacher/dashboard.html',
        {
            'total_groups': total_groups,
            'total_lists': total_lists,
            'total_students': total_students,
            'level_counts': level_counts,
            'level_percentages': level_percentages,
            'group_performance': group_performance,
            'average_score': average_score,
            'challenging_words': challenging_words_data,
        }
    )

@never_cache
@role_required('teacher')
def my_groups(request):
    profesor = request.user.profesor
    grupos = Grupo.objects.filter(profesor=profesor)
    
    return render(
        request, 
        'teacher/my_groups.html',
        {
            'grupos': grupos
        }
    )

@never_cache
@role_required('teacher')
def view_groups(request, group_id):
    grupo = get_object_or_404(Grupo, codigo=group_id)
    
    students = Alumno.objects.filter(
        grupo_alumnos__grupo=grupo
    )
    
    word_list = Palabra.objects.filter(
        lista_palabras__lista__lista_grupos__grupo=grupo
    ).distinct()
    
    return render(
        request, 
        'teacher/view_group.html', 
        {
            'grupo': grupo,
            'students': students,
            'word_list': word_list,
        }
    )

@never_cache
@role_required('teacher')
def word_lists(request):
    return render(request, 'teacher/word_lists.html')

@never_cache
@role_required('student')
def student_home(request):
    alumno = request.user.alumno
    
    grupo_actual = (
        Grupo.objects
        .filter(grupo_alumnos__alumno=alumno)
        .first()
    )
    
    leaderboard = []
    
    if grupo_actual:
        leaderboard = (
            Alumno.objects
            .filter(grupo_alumnos__grupo=grupo_actual)
            .annotate(
                average_score=Avg(
                    'practicas__practica_sesion__porcentaje_aciertos'
                )
            )
            .order_by('-average_score')[:4]
        )
    
    proceso_actual = (
        Proceso_Lista.objects
        .filter(alumno=alumno)
        .select_related('lista')
        .order_by('-fecha_completado')
        .first()
    )
    
    practica_actual = None
    
    if proceso_actual:
        practica_actual = (
            Practica_Sesion.objects
            .filter(
                lista=proceso_actual.lista,
                alumnos__alumno=alumno
            )
            .select_related('juego')
            .order_by('-fecha')
            .first()
        )
        
    mini_games = Juego.objects.filter(
        nombre__in=['Hangman', 'Missing Letters']
    )
    
    return render(
        request, 
        'student/home.html',
        {
            'alumno': alumno,
            'proceso_actual': proceso_actual,
            'practica_actual': practica_actual,
            'mini_games': mini_games,
            'grupo_actual': grupo_actual,
            'leaderboard': leaderboard,
        }
    )

@never_cache
@role_required('student')
def student_groups(request):
    return render(request, 'student/my_groups_student.html')

@never_cache
@role_required('teacher')
def teacher_competitions(request):
    return render(request, 'teacher/competitions.html')

@never_cache
@role_required('student')
def student_competitions(request):
    return render(request, 'student/competitions.html')

@never_cache
@role_required('student')
def lesson1(request):
    return render(request, 'student/lesson1.html')

@never_cache
@role_required('student')
def practices(request):
    return render(request, 'student/practices.html')

@never_cache
@role_required('student')
def progress(request):
    return render(request, 'student/progress.html')

@never_cache
@role_required('teacher')
def statistics(request):
    return render(request, 'teacher/statistics.html')

def logout_view(request):
    logout(request)
    return redirect('login')

@never_cache
@role_required('student')
def student_profile(request):
    return render(request, 'student/student_profile.html')

@never_cache
@role_required('student')
def edit_student_profile(request):
    return render(request, 'student/edit_student_profile.html')

@never_cache
@role_required('teacher')
def teacher_profile(request):
    return render(request, 'teacher/teacher_profile.html')

@never_cache
@role_required('teacher')
def edit_teacher_profile(request):
    return render(request, 'teacher/edit_teacher_profile.html')

@require_POST
def custom_logout_view(request):
    logout(request)
    return redirect('login')

@never_cache
@role_required('administrator')
def gen_panel(request):
    active_teachers = Usuario.objects.filter(
        tipo_usuario__clave='TUSR02',
        is_active=True
    ).count()
    
    registered_users = Usuario.objects.filter(
        is_active=True
    ).count()
    
    total_groups = Grupo.objects.count()
    total_students = Alumno.objects.count()
    total_teachers = Profesor.objects.count()
    
    total_users_for_chart = total_students + total_teachers
    
    if total_users_for_chart > 0:
        students_pct = round(
            (total_students / total_users_for_chart) * 100
        )
        teachers_pct = 100 - students_pct
    else:
        students_pct = 0
        teachers_pct = 0
        
    students_by_level = (
        Nivel.objects
        .annotate(count=Count('alumnos'))
        .order_by('codigo')
    )
    
    challenging_words = (
        Palabra.objects
        .annotate(
            total_attempts=Count('intentos'),
            incorrect_attempts=Count(
                'intentos',
                filter=Q(intentos__acertado=0)
            )
        )
        .filter(total_attempts__gt=0)
    )
    
    challenging_words_data = []
    
    for word in challenging_words:
        miss_rate = round(
            (word.incorrect_attempts / word.total_attempts) * 100
        )
        
        challenging_words_data.append({
            'word': word.significado,
            'miss_rate': miss_rate,
        })
        
    challenging_words_data.sort(
        key=lambda x: x['miss_rate'],
        reverse=True
    )
    
    challenging_words_data = challenging_words_data[:5]
    
    group_scores = (
        Grupo.objects
        .annotate(
            average_score=Avg(
                'grupo_alumnos__alumno__practicas__practica_sesion__porcentaje_aciertos'
            )
        )
        .order_by('nombre')
    )
    
    group_scores_data = []
    
    for group in group_scores:
        score = round(group.average_score or 0)
        
        group_scores_data.append({
            'group': group.nombre,
            'score': score,
        })
        
    if group_scores_data:
        average_score_total = round(
            sum(group['score'] for group in group_scores_data)
            / len(group_scores_data)
        )
    else: 
        average_score_total = 0
    
    context = {
        'active_teachers': active_teachers,
        'registered_users': registered_users,
        'total_groups': total_groups,
        'total_students': total_students,
        'students_pct': students_pct,
        'teachers_pct': teachers_pct,
        'students_by_level': students_by_level,
        'challenging_words': challenging_words_data,
        'group_scores': group_scores_data,
        'average_score_total': average_score_total,
    }
    
    return render(
        request, 
        'administrator/gen_panel.html',
        context
    )

@never_cache
@role_required('administrator')
def admin_teachers(request):
    if request.method == 'POST':
        action = request.POST.get('action')
        
        print("POST RECIBIDO")
        print("ACTION: ",action)
        print("DATOS:", request.POST)
        
        if action == 'add_teacher':
            teacher_code = request.POST.get('teacher_code', '').strip()
            first_name = request.POST.get('first_name', '').strip()
            last_name = request.POST.get('last_name', '').strip()
            second_last_name = request.POST.get('second_last_name', '').strip()
            email = request.POST.get('email', '').strip()
            phone = request.POST.get('phone', '').strip()
            password = request.POST.get('password', '')
            
            if Usuario.objects.filter(codigo=teacher_code).exists():
                messages.error(
                    request,
                    'A user with this teacher code already exists. '
                )
                return redirect('admin_teachers')
            
            if Usuario.objects.filter(correo=email).exists():
                messages.error(
                    request,
                    'A user with this email already exists. '
                )
                return redirect('admin_teachers')
            
            try:
                with transaction.atomic():
                    tipo_teacher = TipoUsuario.objects.get(
                        clave='TUSR02'
                    )
                    
                    usuario = Usuario.objects.create_user(
                        correo=email,
                        password=password,
                        codigo=teacher_code,
                        nombre_pila=first_name,
                        apellidoPaterno=last_name,
                        numero_telefono=phone,
                        tipo_usuario=tipo_teacher,
                        is_active=True,
                        is_staff=False,
                    )
                    
                    Profesor.objects.create(
                        clave=teacher_code,
                        nombre_pila=first_name,
                        apellidoPaterno=last_name,
                        apellidoMaterno=second_last_name,
                        usuario=usuario,
                    )
                    
                messages.success(
                    request,
                    'Teacher created successfully.'
                )
            except Exception as e:
                print("ERROR AL CREAR TEACHER: ")
                print(type(e).__name__)
                print(str(e))
                
                messages.error(
                    request,
                    f'Error creating teacher: {str(e)}'
                )
                
            return redirect('admin_teachers')
    
    search_query = request.GET.get('search', '').strip()
    group_filter = request.GET.get('group', 'ALL')
    status_filter = request.GET.get('status', 'ALL')
    
    teachers = Profesor.objects.select_related('usuario').prefetch_related(
        'grupos__grupo_alumnos__alumno'
    )
    
    if search_query:
        teachers = teachers.filter(
            Q(nombre_pila__icontains=search_query) |
            Q(apellidoPaterno__icontains=search_query) |
            Q(apellidoMaterno__icontains=search_query) |
            Q(usuario__correo__icontains=search_query)
        )
        
    if group_filter != 'ALL':
        teachers = teachers.filter(
            grupos__nombre=group_filter
        ).distinct()
        
    if status_filter == 'ACTIVE':
        teachers = teachers.filter(
            usuario__is_active=True
        )
        
    elif status_filter == 'INACTIVE':
        teachers = teachers.filter(
            usuario__is_active=False
        )
    
    teachers_data = []
    
    for teacher in teachers:
        assigned_groups = []
        students = set()
        
        for group in teacher.grupos.all():
            assigned_groups.append(group.nombre)
            
            for group_student in group.grupo_alumnos.all():
                students.add(group_student.alumno.matricula)
                
        full_name = (
            f"{teacher.nombre_pila} "
            f"{teacher.apellidoPaterno} "
            f"{teacher.apellidoMaterno or ''}"
        ).strip()
        
        teachers_data.append({
            'id': teacher.clave,
            'full_name': full_name,
            'email': teacher.usuario.correo,
            'assigned_groups': assigned_groups,
            'students_count': len(students),
            'status': 'ACTIVE' if teacher.usuario.is_active else 'INACTIVE',
        })
        
    available_groups = (
        Grupo.objects
        .values_list('nombre', flat=True)
        .distinct()
        .order_by('nombre')
    )
        
    context = {
        'teachers': teachers_data,
        'search_query': search_query,
        'group_filter': group_filter,
        'status_filter': status_filter,
        'avaliable_groups': available_groups,
    }
    
    return render(
        request, 
        'administrator/teachers.html',
        context
    )

@never_cache
@role_required('administrator')
def admin_users(request):
    search_query = request.GET.get('search', '').strip()
    role_filter = request.GET.get('role', 'ALL')
    group_filter = request.GET.get('group', 'ALL')
    status_filter = request.GET.get('status', 'ALL')
    
    users = Usuario.objects.select_related(
        'tipo_usuario'
    ).prefetch_related(
        'alumno__grupo_alumnos__grupo',
        'profesor__grupos'
    )
    
    if search_query:
        users = users.filter(
            Q(nombre_pila__icontains=search_query) |
            Q(apellidoPaterno__icontains=search_query) |
            Q(apellidoMaterno__icontains=search_query) |
            Q(correo__icontains=search_query)
        )
        
    if role_filter == 'STUDENT':
        users = users.filter(
            tipo_usuario__clave='TUSR01'
        )
        
    elif role_filter == 'TEACHER':
        users = users.filter(
            tipo_usuario__clave='TUSR02'
        )
        
    elif role_filter == 'ADMIN':
        users = users.filter(
            tipo_usuario__clave='TUSR03'
        )
        
    if status_filter == 'ACTIVE':
        users = users.filter(
            is_active=True
        )
        
    elif status_filter == 'INACTIVE':
        users = users.filter(
            is_active=False
        )
        
    if group_filter != 'ALL':
        users = users.filter(
            Q(alumno__grupo_alumnos__grupo__nombre=group_filter) |
            Q(profesor__grupos__nombre=group_filter)
        ).distinct()
        
    users_data = []
    
    for user in users:
        full_name = (
            f"{user.nombre_pila} "
            f"{user.apellidoPaterno} "
            f"{user.apellidoMaterno or ''}"
        ).strip()
        
        if user.tipo_usuario.clave == 'TUSR01':
            role = 'STUDENT'
            
        elif user.tipo_usuario.clave == 'TUSR02':
            role = 'TEACHER'
            
        elif user.tipo_usuario.clave == 'TUSR03':
            role = 'ADMIN'
            
        else:
            role = user.tipo_usuario.nombre.upper()
            
        groups = []
        
        if role == 'STUDENT':
            try:
                for membership in user.alumno.grupo_alumnos.all():
                    groups.append(membership.grupo.nombre)
            except Alumno.DoesNotExist:
                pass
            
        elif role == 'TEACHER':
            try:
                for group in user.profesor.grupos.all():
                    groups.append(group.nombre)
            except Profesor.DoesNotExist:
                pass
            
        group_display = ', '.join(groups) if groups else 'N/A'
        
        level = 'N/A'
        
        if role == 'STUDENT':
            try:
                level = user.alumno.nivel.codigo
            except Alumno.DoesNotExist:
                pass
            
        users_data.append({
            'id': user.codigo,
            'full_name': full_name,
            'email': user.correo,
            'role': role,
            'group': group_display,
            'level': level,
            'status': 'ACTIVE' if user.is_active else 'INACTIVE',
            'date_joined': 'N/A',
        })
        
    available_groups = (
        Grupo.objects
        .values_list('nombre', flat=True)
        .distinct()
        .order_by('nombre')
    )
    
    context = {
        'users': users_data,
        'total_count': len(users_data),
        'search_query': search_query,
        'role_filter': role_filter,
        'group_filter': group_filter,
        'status_filter': status_filter,
        'available_groups': available_groups,
    }
    
    return render(
        request, 
        'administrator/users.html',
        context
    )

@never_cache
@role_required('administrator')
def admin_academy(request):
    return render(request, 'administrator/academy.html')

@never_cache
@role_required('administrator')
def admin_backups(request):
    return render(request, 'administrator/backups.html')

@never_cache
@role_required('administrator')
def admin_profile(request):
    return render(request, 'administrator/admin_profile.html')

@never_cache
@role_required('student')
def group_view(request):
    return render(request, 'student/group_view.html')

@never_cache
@role_required('student')
def leave_group(request, group_id):
    if request.method == 'POST':
        messages.success(request, 'You have left the group successfully.')
        return redirect('my_groups_student')
    
@never_cache
@role_required('student')
def mini_games_view(request):
    return render(request, 'student/mini_games.html')

@never_cache
@role_required('student')
def hangman_game_view(request):
    return render(request, 'student/hangman_game.html')

@never_cache
@role_required('student')
def missing_letters_game_view(request):
    return render(request, 'student/missing_letters_game.html')
    
@never_cache
@role_required('student')
def student_competitions_view(request):
    # Genera la lista de panales del 1 al 30
    beehives = list(range(1, 31))
    
    context = {
        'beehives': beehives,
    }
    return render(request, 'student/competitions_selecting.html', context)