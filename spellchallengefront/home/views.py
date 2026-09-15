from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth import authenticate, login as auth_login, logout
from django.contrib.auth.decorators import login_required
from django.views.decorators.http import require_POST
from django.views.decorators.cache import never_cache
from functools import wraps
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
    return render(request, 'administrator/gen_panel.html')

@never_cache
@role_required('administrator')
def admin_teachers(request):
    return render(request, 'administrator/teachers.html')

@never_cache
@role_required('administrator')
def admin_users(request):
    return render(request, 'administrator/users.html')

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