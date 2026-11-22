from django.shortcuts import render, redirect, get_object_or_404
from django.contrib import messages
from django.contrib.auth import authenticate, login as auth_login, logout, update_session_auth_hash
from django.contrib.auth.decorators import login_required
from django.views.decorators.http import require_POST, require_GET
from django.views.decorators.cache import never_cache
from functools import wraps
from django.db import transaction
from django.db.models import Count, Avg, Q, ProtectedError, Prefetch, F, Sum, Max
from home.models import Usuario, TipoUsuario, Profesor, Alumno, Administrador, Grupo, Palabra, Notificacion, Pista_Boss_Battle
from home.models import Carrera, Categoria, Alumno_Insignia, Alumno_Practica, Lista_Grupo, Grupo_Alumno
from home.models import Nivel, Dificultad, Dificultad_Juego, Insignia, Intento_Palabra, Lista, Lista_Palabra, Competencia_Profesor
from home.models import Proceso_Lista, Rango, Ranking, Reporte, TipoRanking, UsuarioManager, Juego, Practica_Sesion, Competencia_Alumno
from home.models import Leccion, Lista_Leccion, Competencia, Lista_Competencia, Alumno_Leccion, Grupo_Carrera, Bitacora_Administrador
from home.models import Bitacora_Profesor, Puntaje, Contenido_Leccion, Ejercicio, Ejercicio_Opcion, Estado_Opcion, Copia_Seguridad, Opcion
import json, os, subprocess, re, unicodedata
from .mascot import say
from datetime import date, timedelta, datetime
import random, string, secrets
from django.utils import timezone
from django.conf import settings
from django.http import FileResponse, Http404, JsonResponse
from django.urls import reverse
from home.services.gemini_service import generate_word_content
from home.services.transcription_service import (
    transcribe_audio,
    get_transcription_status,
    TranscriptionUnavailable,
)
from django.core.mail import send_mail
from home.services.achievement_service import unlock_achievement

# Create your views here.

import logging

logger = logging.getLogger(__name__)

SQL_MARKERS = ('MySQL dump', 'MariaDB dump', 'CREATE TABLE', 'INSERT INTO', 'DROP TABLE')

import zipfile
import shutil

def add_folder_to_zip(zf, folder, arc_prefix):
    folder = str(folder)
    if not os.path.isdir(folder):
        return
    for root, _, files in os.walk(folder):
        for name in files:
            full = os.path.join(root, name)
            rel = os.path.relpath(full, folder)
            zf.write(full, os.path.join(arc_prefix, rel))
            
def format_size(n):
    if n >= 1024 * 1024:
        return f'{n / (1024 * 1024):.2f} MB'
    if n >= 1024:
        return f'{n / 1024:.2f} KB'
    return f'{n} B'

def looks_like_sql(head_bytes):
    text = head_bytes.decode('utf-8', errors='ignore')
    return any(marker in text for marker in SQL_MARKERS)

def parse_backup_datos(datos):
    """Reads Size/Type/Description from the datos text. First occurrence wins."""
    info = {'size': '-', 'type': 'Manual', 'description': ''}
    keys = {'Size': 'size', 'Type': 'type', 'Description': 'description'}
    seen = set()
    for line in datos.splitlines():
        key, sep, value = line.partition(':')
        if sep and key in keys and key not in seen:
            info[keys[key]] = value.strip()
            seen.add(key)
    return info

def _update_numero_letras(lista):
    significados = Palabra.objects.filter(
        lista_palabras__lista=lista
    ).values_list('significado', flat=True)
    
    lista.numero_letras = max(
        (sum(1 for char in s if char.isalpha()) for s in significados),
        default=0
    )
    lista.save(update_fields=['numero_letras'])

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
                say(
                    request,
                    "Welcome to Spell-Challenge!",
                    "My name is Crowing, and I will be here to guide you along the way!"
                )
                return redirect('teacher_dashboard')
            
            elif tipo_usuario == 'student':
                say(
                    request,
                    "Welcome to Spell-Challenge!",
                    "Every mistake helps you learn. Keep buzzing!"
                )
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

@transaction.atomic
def signup_student(request):
    niveles = Nivel.objects.all().order_by('codigo')
    carreras = Carrera.objects.all().order_by('nombre')
    
    if request.method == 'POST':
        nombre = request.POST.get('first_name', '').strip()
        apellido_paterno = request.POST.get('paternal_last_name', '').strip()
        apellido_materno = request.POST.get('maternal_last_name', '').strip()
        matricula = request.POST.get('student_id', '').strip()
        correo = request.POST.get('email', '').strip()
        telefono = request.POST.get('phone', '').strip()
        nivel_codigo = request.POST.get('level', '').strip()
        carrera_clave = request.POST.get('career', '').strip()
        password = request.POST.get('password', '')
        confirm_password = request.POST.get('confirm_password', '')
        
        if password != confirm_password:
            messages.error(request, 'Passwords do not match.')
            return render(request, 'users/singup_student.html', {
                'niveles': niveles,
                'carreras': carreras,
            })
            
        if Usuario.objects.filter(correo=correo).exists():
            messages.error(request, 'This email is already registered.')
            return render(request, 'users/singup_student.html', {
                'niveles': niveles,
                'carreras': carreras,
            })
            
        if Alumno.objects.filter(matricula=matricula).exists():
            messages.error(request, 'This Student ID is already registered.')
            return render(request, 'users/singup_student.html', {
                'niveles': niveles,
                'carreras': carreras,
            })
            
        tipo_usuario = TipoUsuario.objects.get(clave='TUSR01')
        
        nivel = Nivel.objects.get(codigo=nivel_codigo)
        carrera = Carrera.objects.get(clave=carrera_clave)
        
        numeros = []
        
        for codigo in Usuario.objects.filter(
            codigo__startswith='USR'
        ).values_list('codigo', flat=True):
            
            try:
                numeros.append(int(codigo[3:]))
            except ValueError:
                pass
            
        siguiente = max(numeros, default=0) + 1
        codigo_usuario = f'USR{siguiente:04d}'
        
        usuario = Usuario.objects.create_user(
            correo=correo,
            password=password,
            codigo=codigo_usuario,
            nombre_pila=nombre,
            apellidoPaterno=apellido_paterno,
            apellidoMaterno=apellido_materno,
            numero_telefono=telefono,
            tipo_usuario=tipo_usuario,
        )
        
        Alumno.objects.create(
            matricula=matricula,
            nombre_pila=nombre,
            apellidoPaterno=apellido_paterno,
            apellidoMaterno=apellido_materno,
            usuario=usuario,
            nivel=nivel,
            carrera=carrera,
        )
        
        messages.success(
            request,
            'Student account created successfully. You can now log in.'
        )
        
        return redirect('login')
    
    return render(request, 'users/singup_student.html', {
        'niveles': niveles,
        'carreras': carreras,
    })

def signup_teacher(request):
    """Registro público para profesores"""
    if request.method == 'POST':
        first_name = request.POST.get('first_name', '').strip()
        paternal_last_name = request.POST.get('paternal_last_name', '').strip()
        maternal_last_name = request.POST.get('maternal_last_name', '').strip()
        teacher_id = request.POST.get('teacher_id', '').strip()
        email = request.POST.get('email', '').strip()
        phone = request.POST.get('phone', '').strip()
        password = request.POST.get('password', '').strip()
        confirm_password = request.POST.get('confirm_password', '').strip()

        # Validaciones de campos obligatorios
        if not all([first_name, paternal_last_name, teacher_id, email, password, confirm_password]):
            messages.error(request, 'Please fill out all required fields.')
            return render(request, 'users/signup_teacher.html')

        if password != confirm_password:
            messages.error(request, 'Passwords do not match.')
            return render(request, 'users/signup_teacher.html')

        # Verificar unicidad de Código y Correo
        if Usuario.objects.filter(codigo=teacher_id).exists():
            messages.error(request, 'A user with this Teacher Code already exists.')
            return render(request, 'users/signup_teacher.html')

        if Usuario.objects.filter(correo=email).exists():
            messages.error(request, 'An account with this email address already exists.')
            return render(request, 'users/signup_teacher.html')

        try:
            with transaction.atomic():
                # Obtener Tipo de Usuario Profesor (TUSR02)
                tipo_teacher = TipoUsuario.objects.get(clave='TUSR02')

                # Crear Usuario Django
                usuario = Usuario.objects.create_user(
                    correo=email,
                    password=password,
                    codigo=teacher_id,
                    nombre_pila=first_name,
                    apellidoPaterno=paternal_last_name,
                    apellidoMaterno=maternal_last_name,
                    numero_telefono=phone,
                    tipo_usuario=tipo_teacher,
                    is_active=True,
                    is_staff=False,
                )

                # Crear Perfil Profesor
                Profesor.objects.create(
                    clave=teacher_id,
                    nombre_pila=first_name,
                    apellidoPaterno=paternal_last_name,
                    apellidoMaterno=maternal_last_name,
                    usuario=usuario,
                )

                messages.success(request, 'Teacher account created successfully! You can now log in.')
                return redirect('login')

        except Exception as e:
            messages.error(request, f'An error occurred during registration: {str(e)}')

    return render(request, 'users/singup_teacher.html')

@never_cache
@role_required('teacher')
def dashboard(request):
    profesor = request.user.profesor
    
    total_competitions = Competencia.objects.filter(
        profesor=profesor
    ).count()
    
    bitacoras = Bitacora_Profesor.objects.filter(
        profesor=profesor
    ).order_by(
        '-fecha_generacion',
        '-hora_generacion'
    )[:5]
    
    grupos = Grupo.objects.filter(profesor=profesor)
    
    total_groups = grupos.count()
    
    total_lists = Lista_Grupo.objects.filter(
        grupo__in=grupos
    ).values('lista').distinct().count()
    
    total_word_lists = Lista.objects.filter(
        profesor=profesor
    ).count()
    
    total_students = Grupo_Alumno.objects.filter(
        grupo__in=grupos
    ).values('alumno').distinct().count()
    
    students_by_level = Alumno.objects.filter(
            grupo_alumnos__grupo__in=grupos
        ).values(
            'nivel__codigo'
        ).annotate(
            total=Count('matricula', distinct=True)
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
            
    alumnos_ids = Grupo_Alumno.objects.filter(
        grupo__in=grupos
    ).values_list(
        'alumno_id',
        flat=True
    ).distinct()
    
    alumnos = Alumno.objects.filter(
        matricula__in=alumnos_ids
    )
    
    total_xp = alumnos.aggregate(
        total=Sum('puntos_experiencia')
    )['total'] or 0
    
    top_students = alumnos.select_related(
        'nivel'
    ).order_by(
        '-puntos_experiencia',
        'nombre_pila'
    )[:5]
    
    return render(
        request, 
        'teacher/dashboard.html',
        {
            'total_groups': total_groups,
            'total_lists': total_lists,
            'total_word_lists': total_word_lists,
            'total_students': total_students,
            'total_competitions': total_competitions,
            'level_counts': level_counts,
            'level_percentages': level_percentages,
            'total_xp': total_xp,
            'top_students': top_students,
            'bitacoras': bitacoras,
        }
    )

@never_cache
@role_required('teacher')
def my_groups(request):
    profesor = request.user.profesor
    
    if request.method == 'POST':
        nombre = request.POST.get('nombre', '').strip()
        nivel = request.POST.get('nivel', '').strip()
        
        if nombre:
            caracteres = string.ascii_uppercase + string.digits
            
            while True:
                codigo = f"GRP{random.randint(10000, 99999)}"
                
                if not Grupo.objects.filter(codigo=codigo).exists():
                    break
                
            while True:
                codigo_union = ''.join(
                    random.choices(caracteres, k=6)
                )
                
                if not Grupo.objects.filter(
                    codigo_union=codigo_union
                ).exists():
                    break
                
            grupo = Grupo.objects.create(
                codigo=codigo,
                codigo_union=codigo_union,
                nombre=nombre,
                fecha_creacion=date.today(),
                ciclo=nivel,
                profesor=profesor,
            )
            
            say(
                request,
                f"Your Class Code is: {codigo_union}",
                "Share it with your student so they can join our class."
            )
            
            return redirect('teacher_groups')
    
    grupos = Grupo.objects.filter(profesor=profesor)
    
    if not grupos.exists() and not request.session.get("mascot_msg"):
        say(
            request,
            "Ready to build your classroom?",
            "Create your first group and invite your students to join Spell-Challenge. Your teaching adventure starts here!"
        )
    
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
    profesor = request.user.profesor
    
    grupo = get_object_or_404(Grupo, codigo=group_id, profesor=profesor)
    
    print("LOGGED TEACHER ID: ",profesor.pk)
    print("GROUP TEACHER ID: ",grupo.profesor_id)
    
    print("ASSIGNED LIST DETAILS: ", list(
        Lista_Grupo.objects.filter(
            grupo=grupo
        ).values(
            'lista__codigo',
            'lista__nombre',
            'lista__profesor_id'
        )
    ))
    
    max_word_lists = 5
    
    if request.method == 'POST':
        lista_codigo = request.POST.get('lista_codigo', '').strip()
        
        current_count = Lista_Grupo.objects.filter(
            grupo=grupo
        ).count()
        
        if current_count >= max_word_lists:
            messages.error(
                request,
                'This group has reached the maximum of 5 Word Lists.'
            )
            return redirect('view_group', group_id=grupo.codigo)
        
        lista = Lista.objects.filter(
            codigo=lista_codigo,
            profesor=profesor
        ).first()
        
        if not lista:
            messages.error(
                request,
                'The selected Word List is not valid.'
            )
            return redirect('view_group', group_id=grupo.codigo)
        
        if Lista_Grupo.objects.filter(
            lista=lista,
            grupo=grupo
        ).exists():
            messages.warning(
                request,
                'This Word List is already assigned to the group.'
            )
            return redirect('view_group', group_id=grupo.codigo)
        
        Lista_Grupo.objects.create(
            lista=lista,
            grupo=grupo
        )
        
        messages.success(
            request,
            f'Word List "{lista.nombre}" added successfully.'
        )
        
        return redirect('view_group', group_id=grupo.codigo)
    
    students = Alumno.objects.filter(
        grupo_alumnos__grupo=grupo
    )
    
    word_lists = Lista.objects.filter(
        profesor=profesor,
        lista_grupos__grupo=grupo,
    ).distinct().annotate(
        total_words=Count('lista_palabras')
    ).order_by('nombre')
    
    print("GROUP: ",grupo.codigo)
    print("ASSIGNED WORD LISTS: ",list(
        Lista_Grupo.objects.filter(grupo=grupo).values('lista', 'grupo')
    ))
    
    available_word_lists = Lista.objects.filter(
        profesor=profesor
    ).exclude(
        lista_grupos__grupo=grupo
    ).distinct().annotate(
        total_words=Count('lista_palabras')
    ).order_by('nombre')
    
    can_add_word_list = word_lists.count() < max_word_lists
    
    return render(
        request, 
        'teacher/view_group.html', 
        {
            'grupo': grupo,
            'students': students,
            'word_lists': word_lists,
            'available_word_lists': available_word_lists,
            'max_word_lists': max_word_lists,
            'can_add_word_list': can_add_word_list,
        }
    )

@never_cache
@role_required('teacher')
def word_lists(request):
    listas = (
        Lista.objects
        .filter(profesor=request.user.profesor)
        .annotate(total_palabras=Count('lista_palabras'))
        .order_by('-fecha_asignacion')
    )
    
    categorias = Categoria.objects.all().order_by('nombre')
    niveles = Nivel.objects.all().order_by('codigo')
    
    if not listas.exists() and not request.session.get("mascot_msg"):
        say(
            request,
            "Let's build your vocabulary!",
            "Create your first Word List and start preparing exciting spelling challenges for your students!"
        )
    
    return render(request, 'teacher/word_lists.html', {
        'listas': listas,
        'categorias': categorias,
        'niveles': niveles,
    })
    
@never_cache
@role_required('teacher')
def view_word_list(request, codigo):
    lista = get_object_or_404(
        Lista,
        codigo=codigo,
        profesor=request.user.profesor
    )
    
    lista_palabras = (
        lista.lista_palabras
        .select_related('palabra', 'palabra__categoria', 'palabra__nivel')
        .all()
    )
    
    grupos_palabras = []
    
    if lista.es_spelling_bee:
        palabras_por_longitud = {
            cantidad: []
            for cantidad in range(6, 14)
        }
        
        for relacion in lista_palabras:
            cantidad_letras = sum(
                1 for char in relacion.palabra.significado
                if char.isalpha()
            )
            
            if cantidad_letras in palabras_por_longitud:
                palabras_por_longitud[cantidad_letras].append(
                    relacion
                )
                
        grupos_palabras = [
            {
                'cantidad': cantidad,
                'palabras': palabras
            }
            for cantidad, palabras in palabras_por_longitud.items()
            if palabras
        ]
        
    else:
        grupos_palabras = [
            {
                'cantidad': None,
                'palabras': lista_palabras
            }
        ]
    
    return render(request, 'teacher/word_list_details.html', {
        'lista': lista,
        'lista_palabras': lista_palabras,
        'grupos_palabras': grupos_palabras,
    })
    
@never_cache
@role_required('teacher')
def add_word_to_list(request, codigo):
    lista = get_object_or_404(
        Lista,
        codigo=codigo,
        profesor=request.user.profesor
    )
    
    if request.method == 'POST':
        significado = request.POST.get('significado', '').strip()
        definicion = request.POST.get('definicion', '').strip()
        ejemplo = request.POST.get('ejemplo', '').strip()
        pronunciacion = request.POST.get('pronunciacion', '').strip()
        nivel_codigo = request.POST.get('nivel', '').strip()
        
        if not significado or len(significado) > 50:
            messages.error(
                request,
                'The word must contain between 1 and 50 characters.'
            )
            return redirect('add_word_to_list', codigo=lista.codigo)
        
        cantidad_letras = sum(
            1 for char in significado
            if char.isalpha()
        )
        
        if lista.es_spelling_bee and not 6 <= cantidad_letras <= 13:
            messages.error(
                request,
                'Spelling Bee words must contain between 6 and 13 letters.'
            )
            return redirect('add_word_to_list', codigo=lista.codigo)
        
        if not pronunciacion or len(pronunciacion) > 100:
            messages.error(
                request,
                'Please enter a valid pronunciation.'
            )
            return redirect('add_word_to_list', codigo=lista.codigo)
        
        if len(definicion) > 255 or len(ejemplo) > 255:
            messages.error(
                request,
                'The definition and example cannot exceed 255 characters.'
            )
            return redirect('add_word_to_list', codigo=lista.codigo)
        
        categoria = Categoria.objects.filter(
            nombre=lista.nombre
        ).first()
        
        nivel = Nivel.objects.filter(
            codigo=nivel_codigo
        ).first()
        
        if categoria is None:
            messages.error(
                request,
                'The category associated with this word list could not be found.'
            )
            return redirect('add_word_to_list', codigo=lista.codigo)
        
        if nivel is None:
            messages.error(request, 'Please select a valid level.')
            return redirect('add_word_to_list', codigo=lista.codigo)
        
        try:
            with transaction.atomic():
                existing_codes = Palabra.objects.values_list(
                    'codigo', flat=True
                )
                
                numbers = [
                    int(code[3:])
                    for code in existing_codes
                    if code.startswith('PAL')
                    and code[3:].isdigit()
                ]
                
                next_number = max(numbers, default=0) + 1
                palabra_codigo = f'PAL{next_number:04d}'
                
                palabra = Palabra.objects.create(
                    codigo=palabra_codigo,
                    significado=significado,
                    definicion=definicion,
                    ejemplo=ejemplo,
                    pronunciacion=pronunciacion,
                    categoria=categoria,
                    nivel=nivel,
                    imagen=request.FILES.get('imagen'),
                    audio=request.FILES.get('audio'),
                )
                
                Lista_Palabra.objects.create(
                    lista=lista,
                    palabra=palabra
                )
                
                palabras_lista = Palabra.objects.filter(
                    lista_palabras__lista=lista
                )
                
                max_letras = max(
                    (
                        sum(1 for char in palabra.significado
                            if char.isalpha())
                        for palabra in palabras_lista
                    ),
                    default=0
                )
                
                lista.numero_letras = max_letras
                lista.save(update_fields=['numero_letras'])
                
            messages.success(
                request,
                f'"{significado}" was added to "{lista.nombre}"'
            )
            return redirect('view_word_list', codigo=lista.codigo)
        
        except Exception:
            messages.error(
                request,
                'The word could not be saved. Please check the information and try again.'
            )
            return redirect('add_word_to_list', codigo=lista.codigo)
        
    niveles = Nivel.objects.all().order_by('codigo')
    
    return render(
        request,
        'teacher/add_word_to_list.html',
        {
            'lista': lista,
            'niveles': niveles,
        }
    )
    
@never_cache
@role_required('teacher')
def edit_word_in_list(request, codigo, codigo_palabra):
    lista = get_object_or_404(
        Lista,
        codigo=codigo,
        profesor=request.user.profesor
    )
    relacion = get_object_or_404(
        Lista_Palabra.objects.select_related('palabra', 'palabra__nivel'),
        lista=lista,
        palabra__codigo=codigo_palabra
    )
    palabra = relacion.palabra
    
    if request.method == 'POST':
        significado = request.POST.get('significado', '').strip()
        definicion = request.POST.get('definicion', '').strip()
        ejemplo = request.POST.get('ejemplo', '').strip()
        pronunciacion = request.POST.get('pronunciacion', '').strip()
        nivel_codigo = request.POST.get('nivel', '').strip()
        
        redirect_error = redirect(
            'edit_word_in_list',
            codigo=lista.codigo,
            codigo_palabra=palabra.codigo
        )
        
        if not significado or len(significado) > 50:
            messages.error(
                request,
                'The word must contain between 1 and 50 characters.'
            )
            return redirect_error
        
        if not pronunciacion or len(pronunciacion) > 100:
            messages.error(request, 'Please enter a valid pronunciation.')
            return redirect_error
        
        if len(definicion) > 255 or len(ejemplo) > 255:
            messages.error(
                request,
                'The definition and example cannot exceed 255 characters.'
            )
            return redirect_error
        
        nivel = Nivel.objects.filter(codigo=nivel_codigo).first()
        if nivel is None:
            messages.error(request, 'Please select a valid level.')
            return redirect_error
        
        try:
            with transaction.atomic():
                palabra.significado = significado
                palabra.definicion = definicion
                palabra.ejemplo = ejemplo
                palabra.pronunciacion = pronunciacion
                palabra.nivel = nivel
                
                nueva_imagen = request.FILES.get('imagen')
                if nueva_imagen:
                    if palabra.imagen:
                        palabra.imagen.delete(save=False)
                    palabra.imagen = nueva_imagen
                elif request.POST.get('remove_imagen') and palabra.imagen:
                    palabra.imagen.delete(save=False)
                    
                nuevo_audio = request.FILES.get('audio')
                if nuevo_audio:
                    if palabra.audio:
                        palabra.audio.delete(save=False)
                    palabra.audio = nuevo_audio
                elif request.POST.get('remove_audio') and palabra.audio:
                    palabra.audio.delete(save=False)
                    
                palabra.save()
                _update_numero_letras(lista)
                
            messages.success(request, f'"{significado}" was updated.')
            return redirect('view_word_list', codigo=lista.codigo)
        
        except Exception:
            messages.error(
                request,
                'The word could not be updated. Please check the information and try again.'
            )
            return redirect_error
        
    niveles = Nivel.objects.all().order_by('codigo')
    
    return render(
        request,
        'teacher/edit_word_in_list.html',
        {
            'lista': lista,
            'palabra': palabra,
            'niveles': niveles,
        }
    )
    
@never_cache
@role_required('teacher')
@require_POST
def delete_word_from_list(request, codigo, codigo_palabra):
    lista = get_object_or_404(
        Lista,
        codigo=codigo,
        profesor=request.user.profesor
    )
    relacion = get_object_or_404(
        Lista_Palabra.objects.select_related('palabra', 'palabra__categoria'),
        lista=lista,
        palabra__codigo=codigo_palabra
    )
    palabra = relacion.palabra
    nombre = palabra.significado
    
    try:
        with transaction.atomic():
            relacion.delete()
            
            if (not palabra.lista_palabras.exists() and palabra.categoria.nombre == lista.nombre):
                try:
                    with transaction.atomic():
                        palabra.delete()
                except ProtectedError:
                    pass
                
            _update_numero_letras(lista)
            
        messages.success(request, f'"{nombre}" was removed from "{lista.nombre}".')
    except Exception:
        messages.error(request, 'The word could not be deleted. Please try again.')
        
    return redirect('view_word_list', codigo=lista.codigo)
    
@never_cache
@require_POST
@role_required('teacher')
def generate_word_suggestions(request, codigo):
    lista = get_object_or_404(
        Lista,
        codigo=codigo,
        profesor=request.user.profesor
    )
    
    significado = request.POST.get('significado', '').strip()
    
    if not significado:
        return JsonResponse(
            {'error': 'Please enter a word first.'},
            status=400
        )
        
    if len(significado) > 50:
        return JsonResponse(
            {'error': 'The word cannot exceed 50 characters.'},
            status=400
        )
        
    try:
        suggestions = generate_word_content(significado)
        
        return JsonResponse({
            'success': True,
            'definition': suggestions['definition'],
            'example': suggestions['example'],
            'pronunciation': suggestions['pronunciation'],
        })
        
    except ValueError as error:
        return JsonResponse(
            {'error': str(error)},
            status=400
        )
        
    except Exception:
        return JsonResponse(
            {
                'error': (
                    'The AI service is currently unavailable. '
                    'Please check your Internet connection and try again, '
                    'or enter the information manually.'
                )
            },
            status=502
        )
    
@never_cache
@role_required('teacher')
def create_word_list(request):
    if request.method == 'POST':
        list_name = request.POST.get('name', '').strip()
        
        es_spelling_bee = request.POST.get('es_spelling_bee') == 'on'
        
        if not list_name:
            messages.error(
                request,
                'Please enter a name for the word list.'
            )
            return redirect('create_word_list')
        
        if len(list_name) > 30:
            messages.error(
                request,
                'The word list name cannot exceed 30 characters.'
            )
            return redirect('create_word_list')
        
        profesor = getattr(request.user, 'profesor', None)
        
        if profesor is None:
            messages.error(
                request,
                'Your account is not associated with a teacher profile.'
            )
            return redirect('teacher_word_lists')
        
        try:
            with transaction.atomic():
                existing_codes = Lista.objects.values_list(
                    'codigo', flat=True
                )
                
                numbers = [
                    int(code[3:])
                    for code in existing_codes
                    if code.startswith('LIS') and code[3:].isdigit()
                ]
                
                next_number = max(numbers, default=0) + 1
                list_code = f'LIS{next_number:02d}'
                
                categoria = Categoria.objects.filter(nombre=list_name).first()
                
                if categoria is None:
                    category_codes = Categoria.objects.values_list('codigo', flat=True)
                    
                    category_numbers = [
                        int(code[3:])
                        for code in category_codes
                        if code.startswith('CAT') and code[3:].isdigit()
                    ]
                    
                    next_category_number = max(category_numbers, default=0) + 1
                    category_code = f'CAT{next_category_number:02d}'
                    
                    categoria = Categoria.objects.create(
                        codigo=category_code,
                        nombre=list_name,
                    )
                
                lista = Lista.objects.create(
                    codigo=list_code,
                    nombre=list_name,
                    fecha_asignacion=timezone.localdate(),
                    fecha_limite=None,
                    numero_letras=0,
                    es_spelling_bee=es_spelling_bee,
                    profesor=profesor,
                )
            
            messages.success(
                request,
                f'Word list "{lista.nombre}" was created successfully.'
            )
            
            return redirect(
                'view_word_list',
                codigo=lista.codigo
            )
            
        except Exception:
            messages.error(
                request,
                'The word list could not be created. Please try again.'
            )
            return redirect('create_word_list')
        
    return render(
        request,
        'teacher/create_word_list.html'
    )
    
@never_cache
@role_required('teacher')
def edit_word_list(request, codigo):
    lista = get_object_or_404(
        Lista,
        codigo=codigo,
        profesor=request.user.profesor
    )
    
    if request.method == 'POST':
        list_name = request.POST.get('name', '').strip()
        
        if not list_name:
            messages.error(
                request,
                'Please enter a name for the word list.'
            )
            return redirect('edit_word_list', codigo=lista.codigo)
        
        if len(list_name) > 30:
            messages.error(
                request,
                'The word list name cannot exceed 30 characters.'
            )
            return redirect('edit_word_list', codigo=lista.codigo)
        
        if list_name == lista.nombre:
            messages.info(
                request,
                'No changes were made to the word list.'
            )
            return redirect('view_word_list', codigo=lista.codigo)
        
        try:
            with transaction.atomic():
                
                categoria = Categoria.objects.filter(
                    nombre=list_name
                ).first()
                
                if categoria is None:
                    category_codes = Categoria.objects.values_list(
                        'codigo',
                        flat=True
                    )
                    
                    category_numbers = [
                        int(code[3:])
                        for code in category_codes
                        if code.startswith('CAT')
                        and code[3:].isdigit()
                    ]
                    
                    next_category_number = max(
                        category_numbers,
                        default=0
                    ) + 1
                    
                    category_code = f'CAT{next_category_number:02d}'
                    
                    categoria = Categoria.objects.create(
                        codigo=category_code,
                        nombre=list_name
                    )
                    
                lista.nombre = list_name
                lista.save(update_fields=['nombre'])
                
            messages.success(
                request,
                f'Word list "{lista.nombre}" was updated successfully.'
            )
            
            return redirect('view_word_list', codigo=lista.codigo)
        
        except Exception:
            messages.error(
                request,
                'The word list could not be updated. Please try again.'
            )
            return redirect('edit_word_list', codigo=lista.codigo)
        
    return render(
        request,
        'teacher/edit_word_list.html',
        {
            'lista': lista,
        }
    )
    
@never_cache
@role_required('teacher')
def delete_word_list(request, codigo):
    
    if request.method != 'POST':
        return redirect('teacher_word_lists')
    
    lista = get_object_or_404(
        Lista,
        codigo=codigo,
        profesor=request.user.profesor
    )
    
    try:
        with transaction.atomic():
            
            tiene_relaciones = (
                lista.lista_grupos.exists()
                or lista.procesos.exists()
                or lista.practicas.exists()
                or lista.lista_competencias.exists()
                or lista.lista_lecciones.exists()
            )
            
            if tiene_relaciones:
                messages.error(
                    request,
                    f'"{lista.nombre}" cannot be deleted because it has '
                    'associated groups, student progress, practices, '
                    'competitions, or lessons.'
                )
                
                return redirect('teacher_word_lists')
            
            nombre_lista = lista.nombre
            
            lista.delete()
            
        messages.success(
            request,
            f'Word list "{nombre_lista}" was deleted successfully.'
        )
        
    except Exception:
        messages.error(
            request,
            'The word list could not be deleted. Please try again.'
        )
        
    return redirect('teacher_word_lists')

@never_cache
@role_required('student')
def student_home(request):
    alumno = request.user.alumno
    
    notificaciones = (
        Notificacion.objects
        .filter(alumno=alumno)
        .select_related('competencia', 'insignia')
        .order_by('-fecha_creacion')
    )
    
    notificaciones_no_leidas = notificaciones.filter(leida=False).count()
    
    grupos_alumno = (
        Grupo.objects
        .filter(grupo_alumnos__alumno=alumno)
        .distinct()
        .order_by('nombre')
    )
    
    grupo_seleccionado = request.GET.get('grupo')
    
    if grupo_seleccionado:
        grupo_actual = grupos_alumno.filter(
            codigo=grupo_seleccionado
        ).first()
    else:
        grupo_actual = grupos_alumno.first()
        
    if grupo_actual is None:
        grupo_actual = grupos_alumno.first()
        
    global_leaderboard = list(
        Alumno.objects
        .all()
        .order_by(
            '-puntos_experiencia',
            'nombre_pila',
            'apellidoPaterno',
            'matricula'
        )
    )
            
    posicion = 0
    xp_anterior = None
            
    for indice, estudiante in enumerate(global_leaderboard):
        if estudiante.puntos_experiencia != xp_anterior:
            posicion = indice + 1
                    
        estudiante.posicion_ranking = posicion
        xp_anterior = estudiante.puntos_experiencia
        
    leaderboard = []
    
    if grupo_actual:
        leaderboard = list(
            Alumno.objects
            .filter(grupo_alumnos__grupo=grupo_actual)
            .order_by(
                '-puntos_experiencia',
                'nombre_pila',
                'apellidoPaterno',
                'matricula'
            )
        )
        
        posicion = 0
        xp_anterior = None
        alumno.posicion_global_ranking = None
        
        for indice, estudiante in enumerate(global_leaderboard):
            if estudiante.puntos_experiencia != xp_anterior:
                posicion = indice + 1
                
            estudiante.posicion_ranking = posicion
            
            if estudiante.matricula == alumno.matricula:
                alumno.posicion_global_ranking = posicion
                
            xp_anterior = estudiante.puntos_experiencia
        
    mini_games = Juego.objects.filter(
        nombre__in=['Hangman', 'Missing Letters', 'Memory Game', 'Word Scramble', 'Boss Battle']
    ).order_by('clave')[:2]
    
    return render(
        request, 
        'student/home.html',
        {
            'alumno': alumno,
            'mini_games': mini_games,
            'grupo_actual': grupo_actual,
            'grupos_alumno': grupos_alumno,
            'leaderboard': leaderboard,
            'global_leaderboard': global_leaderboard,
            'notificaciones': notificaciones,
            'notificaciones_no_leidas': notificaciones_no_leidas,
        }
    )
    
@never_cache
@role_required('student')
@require_POST
def mark_notification_read(request, notification_id):
    alumno = request.user.alumno
    
    notificacion = get_object_or_404(
        Notificacion,
        id=notification_id,
        alumno=alumno
    )
    
    if not notificacion.leida:
        notificacion.leida = True
        notificacion.save(update_fields=['leida'])
        
    return redirect(f"{reverse('student_home')}?notifications=1")

@never_cache
@role_required('student')
def student_groups(request):
    alumno = get_object_or_404(
        Alumno,
        usuario=request.user
    )
    
    def get_groups():
        grupos = (
            Grupo.objects
            .filter(grupo_alumnos__alumno=alumno)
            .select_related('profesor')
            .prefetch_related(
                'grupo_alumnos__alumno',
                'lista_grupos'
            )
            .distinct()
        )
        
        groups = []
        
        for grupo in grupos:
            teacher = grupo.profesor
            
            teacher_name = (
                f"{teacher.nombre_pila} "
                f"{teacher.apellidoPaterno} "
                f"{teacher.apellidoMaterno}"
            ).strip()
            
            student_count = grupo.grupo_alumnos.count()
            list_count = grupo.lista_grupos.count()
            
            groups.append({
                'id': grupo.codigo,
                'nombre': grupo.nombre,
                'teacher_name': teacher_name,
                'student_count': student_count,
                'list_count': list_count,
                'profesor': teacher,  # <--- AGREGAR ESTA LÍNEA
            })
            
        return groups
    
    if request.method == 'POST':
        codigo = request.POST.get('group_code', '').strip().upper()
        
        if not codigo:
            return render(
                request,
                'student/my_groups_student.html',
                {
                    'groups': [],
                    'join_error': 'Please enter a group code.',
                }
            )
            
        try:
            grupo = Grupo.objects.get(codigo_union=codigo)
            
        except Grupo.DoesNotExist:
            return render(
                request,
                'student/my_groups_student.html',
                {
                    'groups': [],
                    'join_error': 'Group code not found.',
                }
            )
            
        if Grupo_Alumno.objects.filter(
            grupo=grupo,
            alumno=alumno
        ).exists():
            return render(
                request,
                'student/my_groups_student.html',
                {
                    'groups': [],
                    'join_error': 'You are already a member of this group.',
                }
            )
            
        Grupo_Alumno.objects.create(
            grupo=grupo,
            alumno=alumno
        )
        
        return redirect('student_groups')
    
    groups = get_groups()
    
    if not groups and not request.session.get("mascot_msg"):
        say(
            request,
            "Ready to join your classroom?",
            "Ask your teacher for a Group Code and enter it to join your class. Your learning adventure starts here!"
        )
    
    return render(
        request, 
        'student/my_groups_student.html',
        {
            'groups': groups
        }
    )

@never_cache
@role_required('teacher')
def teacher_competitions(request):
    profesor = request.user.profesor
    
    if request.method == 'POST':
        nombre = request.POST.get('nombre', '').strip()
        lista_codigo = request.POST.get('lista', '').strip()
        general_spelling_bee = request.POST.get('general_spelling_bee') == 'yes'
        fecha = request.POST.get('fecha', '')
        hora = request.POST.get('hora', '')
        
        # Validar campos obligatorios
        if not nombre or (not general_spelling_bee and not lista_codigo) or not fecha or not hora:
            messages.error(
                request,
                'Please complete all required fields.'
            )
            return redirect('teacher_competitions')
        
        lista = None
        
        # Validación de la lista seleccionada
        if not general_spelling_bee:
            lista = Lista.objects.filter(
                codigo=lista_codigo,
                profesor=profesor
            ).first()
            
            if not lista:
                messages.error(request, 'The selected word list is not valid.')
                return redirect('teacher_competitions')
            
            # VALIDACIÓN CLAVE: Impedir listas con 0 palabras
            if not lista.lista_palabras.exists():
                messages.error(
                    request,
                    f'The word list "{lista.nombre}" contains no words. Please select a list with at least 1 word.'
                )
                return redirect('teacher_competitions')
        
        # Validar que la fecha y hora no hayan pasado
        try:
            competition_datetime = timezone.make_aware(
                datetime.combine(
                    datetime.strptime(fecha, '%Y-%m-%d').date(),
                    datetime.strptime(hora, '%H:%M').time()
                )
            )
            if competition_datetime < timezone.localtime():
                messages.error(
                    request,
                    'The competition date and time cannot be in the past.'
                )
                return redirect('teacher_competitions')
            
        except ValueError:
            messages.error(
                request,
                'The selected date or time is invalid.'
            )
            return redirect('teacher_competitions')
        
        # Generar código correlativo para la competencia (COM01, COM02, ...)
        try:
            with transaction.atomic():
                number = 1
                while Competencia.objects.filter(
                    codigo=f'COM{number:02d}'
                ).exists():
                    number += 1
                    
                codigo = f'COM{number:02d}'
                
                competencia = Competencia.objects.create(
                    codigo=codigo,
                    nombre=nombre,
                    fecha=fecha,
                    hora=hora,
                    profesor=profesor,
                    estado='Upcoming',
                    tipo='GENERAL' if general_spelling_bee else 'LIST'
                )
                
                # Asociar la lista de palabras si no es General Spelling Bee
                if lista:
                    Lista_Competencia.objects.create(
                        lista=lista,
                        competencia=competencia
                    )
                
                # Registro en la bitácora del profesor
                number_bitacora = 1
                while Bitacora_Profesor.objects.filter(
                    codigo=f'BITP{number_bitacora:02d}'
                ).exists():
                    number_bitacora += 1
                    
                codigo_bitacora = f'BITP{number_bitacora:02d}'
                now = timezone.localtime()
                
                Bitacora_Profesor.objects.create(
                    codigo=codigo_bitacora,
                    fecha_generacion=now.date(),
                    hora_generacion=now.time(),
                    accion=f'Created a new competition: {nombre}.',
                    profesor=profesor
                )
                
                messages.success(
                    request,
                    'Competition created successfully.'
                )
                
                say(
                    request,
                    "A new challenge is ready!",
                    "Your competition has been created successfully. Get ready to see your students shine!"
                )
                
        except Exception as e:
            messages.error(request, f'Error creating competition: {str(e)}')
            
        return redirect('teacher_competitions')
    
    competitions = Competencia.objects.filter(
        profesor=profesor
    ).prefetch_related(
        'lista_competencias__lista'
    ).order_by('-fecha', 'hora')
    
    if not competitions.exists() and not request.session.get("mascot_msg"):
        say(
            request,
            "Ready for the next challenge?",
            "Create your first Spelling Bee competition and give your students a chance to show what they have learned!"
        )
    
    groups = Grupo.objects.filter(
        profesor=profesor
    ).order_by('nombre')
    
    word_lists = Lista.objects.filter(
        profesor=profesor
    ).annotate(
        total_words=Count('lista_palabras')
    ).order_by('nombre')
    
    now = timezone.localtime()
    today = now.date()
    
    total_competitions = competitions.count()
    active_competitions = competitions.filter(estado='Active').count()
    finished_competitions = competitions.filter(estado='Finished').count()
    upcoming_competitions = competitions.filter(estado='Upcoming').count()
    
    context = {
        'competitions': competitions,
        'groups': groups,
        'word_lists': word_lists,
        'total_competitions': total_competitions,
        'active_competitions': active_competitions,
        'finished_competitions': finished_competitions,
        'upcoming_competitions': upcoming_competitions,
        'today': today,
    }
    
    return render(
        request, 
        'teacher/competitions.html',
        context
    )

@never_cache
@role_required('student')
def student_competitions(request):
    alumno = request.user.alumno
    
    competencias = (
        Competencia.objects
        .filter(
            profesor__grupos__grupo_alumnos__alumno=alumno
        )
        .select_related('profesor')
        .distinct()
        .order_by(
            'fecha',
            'hora'
        )
    )
    
    if not request.session.get("mascot_msg"):
        if competencias.exists():
            say(
                request,
                "Ready to bee a champion?",
                "Your next spelling challenge awaits! Give it your best, trust your knowledge and show everyone what you can do!"
            )
        else:
            say(
                request,
                "No challenges yet?",
                "Don't worry! New competitions may be coming soon. Keep practicing and get ready to show off your spelling skills!"
            )
    
    return render(
        request, 
        'student/competitions.html',
        {
            'competencias': competencias,
        }
    )

@never_cache
@role_required('student')
def lesson(request, clave_leccion):
    
    leccion = get_object_or_404(
        Leccion,
        clave=clave_leccion
    )
    
    siguiente_numero = int(leccion.clave[3:]) + 1
    
    siguiente_leccion = Leccion.objects.filter(
        clave=f'LEC{siguiente_numero:02d}'
    ).first()
    
    additional_words = Palabra.objects.filter(
        lista_palabras__lista__lista_grupos__grupo__grupo_alumnos__alumno=request.user.alumno
    ).distinct().order_by('significado')
    
    curricular_words = Palabra.objects.filter(
        leccion_palabras__leccion=leccion
    ).distinct().order_by('significado')
    
    vocabulary_exercises = Ejercicio.objects.filter(
        leccion=leccion,
        contenido_leccion__codigo='CON02'
    ).order_by('clave')
    
    grammar_exercises = Ejercicio.objects.filter(
        leccion=leccion,
        contenido_leccion__codigo='CON03'
    ).order_by('clave')
    
    listening_exercises = Ejercicio.objects.filter(
        leccion=leccion,
        contenido_leccion__codigo='CON04'
    ).order_by('clave')
    
    speaking_exercises = Ejercicio.objects.filter(
        leccion=leccion,
        contenido_leccion__codigo='CON05'
    ).order_by('clave')
    
    speaking_round_token = secrets.token_urlsafe(32)
    
    lesson_token_key = f'lesson_speaking_token_{leccion.clave}'
    lesson_exercises_key = f'lesson_speaking_exercises_{leccion.clave}'
    lesson_counted_key = f'lesson_speaking_counted_{leccion.clave}'
    
    expected_speaking_exercises = {
        ejercicio.clave: ejercicio.descripcion
        for ejercicio in speaking_exercises
    }
    
    request.session[lesson_token_key] = speaking_round_token
    request.session[lesson_exercises_key] = expected_speaking_exercises
    request.session[lesson_counted_key] = []
    
    review_exercises = Ejercicio.objects.filter(
        leccion=leccion,
        contenido_leccion__codigo='CON06'
    ).order_by('clave')
    
    context = {
        'leccion': leccion,
        'siguiente_leccion': siguiente_leccion,
        'additional_words': additional_words,
        'curricular_words': curricular_words,
        'vocabulary_exercises': vocabulary_exercises,
        'grammar_exercises': grammar_exercises,
        'listening_exercises': listening_exercises,
        'speaking_exercises': speaking_exercises,
        'speaking_round_token': speaking_round_token,
        'review_exercises': review_exercises,
    }
    
    return render(request, 'student/lesson1.html', context)

@never_cache
@require_POST
@role_required('student')
def transcribe_speaking(request):

    activity_type = request.POST.get('activity_type', 'practice')

    # PRACTICE SPEAKING
    if activity_type == 'practice':

        round_token = request.POST.get('round_token')
        session_token = request.session.get('pk_round_token')

        if not round_token or round_token != session_token:
            return JsonResponse(
                {'error': 'Invalid or expired game session.'},
                status=400
            )

        try:
            word_index = int(request.POST.get('word_index'))
        except (TypeError, ValueError):
            return JsonResponse(
                {'error': 'Invalid exercise index.'},
                status=400
            )

        expected_words = request.session.get(
            'pk_expected_words',
            []
        )

        if word_index < 0 or word_index >= len(expected_words):
            return JsonResponse(
                {'error': 'Invalid exercise index.'},
                status=400
            )

        expected_answer = expected_words[word_index]

        counted_items = request.session.get(
            'pk_counted_words',
            []
        )

        counted_key = 'pk_counted_words'
        
    #PRACTICE SPELLING
    elif activity_type == 'spelling':
        
        round_token = request.POST.get('round_token')
        session_token = request.session.get('ps_round_token')
        
        if not round_token or round_token != session_token:
            return JsonResponse(
                {'error': 'Invalid or expired spelling session.'},
                status=400
            )

    # LESSON SPEAKING
    elif activity_type == 'lesson':

        round_token = request.POST.get('round_token')
        lesson_code = request.POST.get('lesson_code')
        exercise_code = request.POST.get('exercise_code')

        if not lesson_code or not exercise_code or not round_token:
            return JsonResponse(
                {'error': 'Missing lesson exercise information.'},
                status=400
            )

        lesson_token_key = f'lesson_speaking_token_{lesson_code}'
        lesson_exercises_key = f'lesson_speaking_exercises_{lesson_code}'
        lesson_counted_key = f'lesson_speaking_counted_{lesson_code}'

        session_token = request.session.get(lesson_token_key)

        if round_token != session_token:
            return JsonResponse(
                {'error': 'Invalid or expired lesson session.'},
                status=400
            )

        expected_exercises = request.session.get(
            lesson_exercises_key,
            {}
        )

        if exercise_code not in expected_exercises:
            return JsonResponse(
                {'error': 'Invalid lesson exercise.'},
                status=400
            )

        expected_answer = expected_exercises[exercise_code]

        counted_items = request.session.get(
            lesson_counted_key,
            []
        )

        counted_key = lesson_counted_key

    else:
        return JsonResponse(
            {'error': 'Invalid speaking activity.'},
            status=400
        )

    audio_file = request.FILES.get('audio')

    if not audio_file:
        return JsonResponse(
            {'error': 'No audio recording was received.'},
            status=400
        )

    if audio_file.size == 0:
        return JsonResponse(
            {'error': 'The audio recording is empty.'},
            status=400
        )

    if audio_file.size > 5 * 1024 * 1024:
        return JsonResponse(
            {'error': 'The audio recording cannot exceed 5 MB.'},
            status=400
        )
    allowed_types = {
        'audio/webm',
        'audio/webm;codecs=opus',
        'audio/ogg',
        'audio/mp4',
        'audio/mpeg',
        'audio/wav',
    }
    if audio_file.content_type not in allowed_types:
        return JsonResponse(
            {'error': 'Unsupported audio format.'},
            status=400
        )

    try:
        transcription = transcribe_audio(audio_file)

        if not transcription or not transcription.strip():
            return JsonResponse(
                {'error': 'No speech could be transcribed.'},
                status=400
            )
            
        #PRACTICE SPELLING RESPONSE
        if activity_type == 'spelling':
            return JsonResponse({
                'success': True,
                'transcription': transcription,
            })

        import re
        
        answer = re.sub(
            r'\s+',
            ' ',
            re.sub(
                r'^\s*say\b[\s,:-]*',
                '',
                transcription.lower()
            )
        )
        
        answer = re.sub(
            r'[-]',
            ' ',
            answer
        )

        answer = re.sub(
            r'[^\w\s]',
            '',
            answer
        ).strip()
        
        answer = re.sub(
            r'\s+',
            ' ',
            answer
        )

        expected = re.sub(
            r'^\s*say\b[\s,:-]*',
            '',
            expected_answer.lower()
        )
        
        expected = re.sub(
            r'[-]',
            ' ',
            expected
        )
        
        expected = re.sub(
            r'[^\w\s]',
            '',
            expected
        )
        
        expected = re.sub(
            r'\s+',
            ' ',
            expected
        ).strip()
        
        def normalize_number_words(text):
            small_numbers = {
                'zero': 0,
                'one': 1,
                'two': 2,
                'three': 3,
                'four': 4,
                'five': 5,
                'six': 6,
                'seven': 7,
                'eight': 8,
                'nine': 9,
                'ten': 10,
                'eleven': 11,
                'twelve': 12,
                'thirteen': 13,
                'fourteen': 14,
                'fifteen': 15,
                'sixteen': 16,
                'seventeen': 17,
                'eighteen': 18,
                'nineteen': 19,
            }
                    
            tens_numbers = {
                'twenty': 20,
                'thirty': 30,
                'forty': 40,
                'fifty': 50,
                'sixty': 60,
                'seventy': 70,
                'eighty': 80,
                'ninety': 90,
            }
                    
            words = text.split()
            normalized = []
                    
            i = 0
                    
            while i < len(words):
                word = words[i]
                        
                if word in tens_numbers:
                    number = tens_numbers[word]
                            
                    if (
                        i + 1 < len(words)
                        and words[i + 1] in small_numbers
                        and 1 <= small_numbers[words[i + 1]] <= 9
                    ):
                        number += small_numbers[words[i + 1]]
                        i += 1
                                
                    normalized.append(str(number))
                        
                elif word in small_numbers:
                    normalized.append(str(small_numbers[word]))
                            
                else:
                    normalized.append(word)
                            
                i += 1
                        
            return ' '.join(normalized)
        
        print("ANSWER BEFORE NORMALIZATION: ", answer)
        print("EXPECTED BEFORE NORMALIZATION: ", expected)
        
        answer = normalize_number_words(answer)
        expected = normalize_number_words(expected)
        
        print("ANSWER AFTER NORMALIZATION: ", answer)
        print("EXPECTED AFTER NORMALIZATION: ", expected)
        
        is_correct = answer == expected
        
        current_item = (
            word_index
            if activity_type == 'practice'
            else exercise_code
        )

        if is_correct and current_item not in counted_items:

            alumno = request.user.alumno

            Alumno.objects.filter(pk=alumno.pk).update(
                palabras_pronunciadas=F('palabras_pronunciadas') + 1
            )

            counted_items.append(current_item)

            request.session[counted_key] = counted_items

            alumno.refresh_from_db(
                fields=['palabras_pronunciadas']
            )

            # INS17 - Voice Explorer
            if alumno.palabras_pronunciadas >= 50:
                unlock_achievement(alumno, 'INS17')

            # INS18 - Speaking Star
            if alumno.palabras_pronunciadas >= 100:
                unlock_achievement(alumno, 'INS18')

            # INS19 - Voice Champion
            if alumno.palabras_pronunciadas >= 500:
                unlock_achievement(alumno, 'INS19')

        return JsonResponse({
            'success': True,
            'transcription': transcription,
            'is_correct': is_correct,
            'words_counted': len(counted_items)
        })
        
    except TranscriptionUnavailable as error:
        
        return JsonResponse(
            {
                'success': False,
                'error_type': error.error_type,
                'error': (
                    'The transcription service is temporarily unavailable. '
                    'Please wait before trying again.'
                ),
                'retry_after': error.retry_after,
            },
            status=(
                error.status_code
                if error.status_code in (429, 503)
                else 503
            )
        )

    except Exception as error:
        print("TRANSCRIPTION ERROR TYPE: ", type(error).__name__)
        print("TRANSCRIPTION ERROR: ", repr(error))
        print("TRANSCRIPTION ERROR CODE: ", getattr(error, 'code', None))
        print("TRANSCRIPTION ERROR STATUS: ", getattr(error, 'status_code', None))
        print("TRANSCRIPTION ERROR MESSAGE: ", str(error))

        gemini_status = getattr(error, 'code', None)
        
        if not isinstance(gemini_status, int):
            gemini_status = getattr(error, 'status_code', None)
            
        if not isinstance(gemini_status, int):
            response = getattr(error, 'response', None)
            gemini_status = getattr(response, 'status_code', None)

        if gemini_status is None:
            gemini_status = getattr(error, 'status_code', None)
            
        error_details = str(error).lower()
        
        transcription_status = get_transcription_status()
        
        retry_after = transcription_status.get(
            'retry_after',
            0
        )

        if gemini_status == 429:
            
            daily_quota = (
                'per day' in error_details
                or 'daily' in error_details
            )
            
            if daily_quota:
                return JsonResponse(
                    {
                        'error_type': 'daily_quota',
                        'error': (
                            'The daily transcription quota has been reached. '
                            'Please try again after the quota resets.'
                        ),
                        'retry_after': retry_after,
                    }, 
                    status=429
                )
                
            return JsonResponse(
                {
                    'error_type': 'rate_limit',
                    'error': (
                        'The transcription request limit has been reached. '
                        'Please wait before trying again.'
                    ),
                    'retry_after': retry_after,
                },
                status=429
            )
            
        if gemini_status == 503:
            return JsonResponse(
                {
                    'error_type': 'service_busy',
                    'error': (
                        'The transcription service is temporarily busy. '
                        'Please try again in a few moments.'
                    ),
                    'retry_after': retry_after,
                },
                status=503
            )
        return JsonResponse(
            {
                'error_type': 'service_unavailable',
                'error': (
                    'The transcription service is currently unavailable. '
                    'Please try again.'
                )
            },
            status=502
        )
        
@never_cache
@require_GET
@role_required('student')
def transcription_status(request):
    
    status = get_transcription_status()
    
    return JsonResponse({
        'available': status['available'],
        'reason': status['reason'],
        'retry_after': status['retry_after'],
    })
        
def normalize_boss_word(word):
    normalized = unicodedata.normalize(
        'NFKD',
        word.upper().strip()
    ).encode(
        'ASCII',
        'ignore'
    ).decode('ASCII')
    
    return re.sub(
        r'[^A-Z]',
        '',
        normalized
    )
    
def get_boss_battle_clue(word, round_index):
    
    if round_index < 3:
        return word['clue_easy']
    
    elif round_index < 6:
        return word['clue_medium']
    
    return word['clue_hard']

@never_cache
@role_required('student')
def practices(request):
    
    alumno = request.user.alumno
    
    if request.method == 'POST':
        game = request.POST.get('game')
        round_token = request.POST.get('round_token')
        
        valid_games = {
            'hangman': 'ph_hangman_round_token',
            'missing_letters': 'ph_missing_round_token',
            'memory_game': 'ph_memory_round_token',
            'word_search': 'ph_word_search_round_token',
        }
        
        if game not in valid_games:
            return JsonResponse({
                'success': False,
                'message': 'Invalid or expired game session.'
            }, status=400)
            
        session_key = valid_games[game]
        session_token = request.session.get(session_key)
        
        if not round_token or round_token != session_token:
            return JsonResponse({
                'success': False,
                'message': 'Invalid or expired game session.'
            }, status=400)
            
        del request.session[session_key]
        
        try:
            errors = int(request.POST.get('errors', 0))
        except (TypeError, ValueError):
            errors = 0
            
        errors = max(0, errors)
        
        completed = request.POST.get('completed', 'true') == 'true'
        
        if game == 'memory_game':
            if not completed:
                xp_earned = 0
            else:
                xp_earned = max(0, 20 - (errors // 5))
        elif game == 'word_search':
            if not completed:
                xp_earned = 0
            else:
                xp_earned = max(0, 20 - errors)
        else:
            xp_earned = max(0, 20 - errors)
            
        Alumno.objects.filter(pk=alumno.pk).update(
            puntos_experiencia=F('puntos_experiencia') + xp_earned
        )
        
        alumno.refresh_from_db(
            fields=['puntos_experiencia']
        )
        
        game_achievements = {
            'hangman': 'INS01',
            'missing_letters': 'INS02',
            'memory_game': 'INS03',
            'word_search': 'INS04',
        }
        
        if completed:
            achievement = game_achievements.get(game)
            
            if achievement:
                unlock_achievement(alumno, achievement)
                
            if errors == 0:
                unlock_achievement(alumno, 'INS09')
                
        if alumno.puntos_experiencia >= 100:
            unlock_achievement(alumno, 'INS14')
            
        if alumno.puntos_experiencia >= 500:
            unlock_achievement(alumno, 'INS16')
        
        new_round_token = secrets.token_urlsafe(32)
        request.session[session_key] = new_round_token
        
        return JsonResponse({
            'success': True,
            'game': game,
            'errors': errors,
            'xp_earned': xp_earned,
            'total_xp': alumno.puntos_experiencia,
            'round_token': new_round_token,
        })
        
    if not request.session.get("mascot_msg"):
        say(
            request,
            "Ready for a new challenge?",
            "Welcome to Practice Hall! Play Mini Games, improve your English skills, and earn XP along the way. Let's make learning fun!"
        )
    
    niveles = Nivel.objects.prefetch_related(
        'practicas__lecciones'
    ).order_by('codigo')
    
    grupos = Grupo_Alumno.objects.filter(
        alumno=alumno
    ).values_list(
        'grupo',
        flat=True
    )
    
    listas = Lista_Grupo.objects.filter(
        grupo__in=grupos
    ).values_list(
        'lista',
        flat=True
    )
    
    palabras = Palabra.objects.filter(
        lista_palabras__lista__in=listas
    ).distinct().order_by('codigo')
    
    vocabulary = []
    
    for palabra in palabras:
        vocabulary.append({
            'word': palabra.significado.upper(),
            'meaning': palabra.definicion,
            'example': palabra.ejemplo,
            'image': palabra.imagen.url if palabra.imagen else '',
            'audio': palabra.audio.url if palabra.audio else '',
            'category': palabra.categoria.nombre,
            'level': palabra.nivel.codigo,
        })
        
    word_search_vocabulary = {
        length: [] for length in range(6, 13)
    }
    
    all_words = Palabra.objects.all().order_by(
        'codigo'
    ).values_list(
        'significado',
        flat=True
    )
    
    for significado in all_words:
        normalized_word = unicodedata.normalize(
            'NFKD',
            significado.upper()
        ).encode(
            'ASCII',
            'ignore'
        ).decode('ASCII')
        
        normalized_word = re.sub(
            r'[^A-Z]',
            '',
            normalized_word
        )
        
        word_length = len(normalized_word)
        
        if 6 <= word_length <= 12:
            if normalized_word not in word_search_vocabulary[word_length]:
                word_search_vocabulary[word_length].append(
                    normalized_word
                )
        
    memory_words = Palabra.objects.filter(
        imagen__isnull=False
    ).exclude(
        imagen=''
    )
    
    memory_vocabulary = []
    
    for palabra in memory_words:
        memory_vocabulary.append({
            'word': palabra.significado.upper(),
            'image': palabra.imagen.url,
        })
        
    memory_difficulties = list(
        Dificultad_Juego.objects.filter(
            juego='J04'
        ).select_related(
            'dificultad'
        ).values(
            'dificultad__clave',
            'dificultad__nombre',
            'dificultad__descripcion'
        )
    )
    
    round_tokens = {
        'hangman': secrets.token_urlsafe(32),
        'missing_letters': secrets.token_urlsafe(32),
        'memory_game': secrets.token_urlsafe(32),
        'word_search': secrets.token_urlsafe(32),
    }
    
    request.session['ph_hangman_round_token'] = round_tokens['hangman']
    request.session['ph_missing_round_token'] = round_tokens['missing_letters']
    request.session['ph_memory_round_token'] = round_tokens['memory_game']
    request.session['ph_word_search_round_token'] = round_tokens['word_search']
    
    context = {
        'niveles': niveles,
        'vocabulary': vocabulary,
        'memory_vocabulary': memory_vocabulary,
        'memory_difficulties': memory_difficulties,
        'word_search_vocabulary': word_search_vocabulary,
        'round_tokens': round_tokens,
    }
    
    return render(request, 'student/practices.html', context)

def generate_boss_battle_options(correct_answer, correct_display, excluded_answers=None):
    excluded_answers = set(excluded_answers or [])
    excluded_answers.add(correct_answer)
    
    distractors = []
    used_answers = set(excluded_answers)
    
    #GET GENERAL WORD CATALOG
    
    all_words = Palabra.objects.values_list(
        'significado',
        flat=True
    )
    
    for meaning in all_words:
        normalized = normalize_boss_word(meaning)
        
        if not normalized or not 3 <= len(normalized) <= 10:
            continue
        
        if normalized in used_answers:
            continue
        
        used_answers.add(normalized)
        
        distractors.append(meaning.strip())
        
    #VERIFY AVAILABLE DISTRACTORS
    
    if len(distractors) < 3:
        return None
    
    #GENERATE FOUR RANDOM OPTIONS
    
    options = random.sample(distractors, 3)
    
    options.append(correct_display)
    
    random.shuffle(options)
    
    return options

@never_cache
@role_required('student')
@require_POST
def boss_battle_start(request):

    # GET WORDS WITH STORED BOSS BATTLE CLUES

    all_words = Pista_Boss_Battle.objects.select_related(
        'palabra'
    ).all()

    candidates = []
    used_words = set()

    # FILTER VALID WORDS

    for record in all_words:

        answer = normalize_boss_word(
            record.palabra.significado
        )

        clue_easy = record.pista_facil.strip()
        clue_medium = record.pista_intermedia.strip()
        clue_hard = record.pista_dificil.strip()

        if not 3 <= len(answer) <= 10:
            continue

        if not clue_easy or not clue_medium or not clue_hard:
            continue

        if answer in used_words:
            continue

        used_words.add(answer)

        candidates.append({
            'codigo': record.palabra.codigo,
            'answer': answer,
            'display_answer': record.palabra.significado.strip(),
            'clue_easy': clue_easy,
            'clue_medium': clue_medium,
            'clue_hard': clue_hard,
        })

    # VERIFY AVAILABLE WORDS

    if len(candidates) < 10:

        return JsonResponse({
            'success': False,
            'message': 'Not enough words with Boss Battle clues available.'
        }, status=400)

    # SELECT 10 RANDOM WORDS

    selected_words = random.sample(
        candidates,
        10
    )
    
    excluded_answers = {
        word['answer'] for word in selected_words
    }
    
    for word in selected_words:
        
        word['options'] = generate_boss_battle_options(
            correct_answer=word['answer'],
            correct_display=word['display_answer'],
            excluded_answers=excluded_answers
        )
    
        if word['options'] is None:
            
            return JsonResponse({
                'success': False,
                'message': 'Not enough words available to generate answer options.'
            }, status=400)

    # INITIALIZE BATTLE SESSION

    battle_token = secrets.token_urlsafe(32)

    request.session['boss_battle'] = {
        'battle_token': battle_token,
        'round_token': secrets.token_urlsafe(16),
        'round_started_at': timezone.now().timestamp(),
        'words': selected_words,
        'current_index': 0,
        'king_bee_lives': 10,
        'beenary_lives': 10,
        'correct_answers': 0,
        'incorrect_answers': 0,
        'xp_awarded': False,
        'sudden_death': False,
        'finished': False,
    }

    request.session.modified = True

    # RETURN FIRST ROUND
    
    return JsonResponse({
        'success': True,
        'battle_token': battle_token,
        'round_token': request.session['boss_battle']['round_token'],
        'round': 1,
        'total_rounds': 10,
        'time_limit': 10,
        'king_bee_lives': 10,
        'beenary_lives': 10,
        'clue': selected_words[0]['clue_easy'],
        'options': selected_words[0]['options'],
    })
    
@never_cache
@role_required('student')
@require_POST
def boss_battle_answer(request):
    #GET CURRENT BATTLE
    
    battle = request.session.get('boss_battle')

    if (
        not battle
        or 'king_bee_lives' not in battle
        or 'beenary_lives' not in battle
        or 'current_index' not in battle
        or 'words' not in battle
    ):

        request.session.pop('boss_battle', None)

        return JsonResponse({
            'success': False,
            'message': 'Invalid or expired Boss Battle session. Please start a new battle.'
        }, status=400)
        
    #VALIDATE BATTLE TOKEN
    
    battle_token = request.POST.get('battle_token')
    
    if not battle_token or battle_token != battle.get('battle_token'):
        return JsonResponse({
            'success': False,
            'message': 'Invalid or expired Boss Battle session.'
        })
        
    #VALIDATE ROUND TOKEN
    
    round_token = request.POST.get('round_token')
    
    #CHECK IF THIS ROUND WAS ALREADY PROCESSED
    
    if (
        round_token
        and round_token == battle.get('last_round_token')
        and battle.get('last_response')
    ):
        return JsonResponse(
            battle['last_response']
        )
        
    #CHECK IF BATTLE HAS ALREADY FINISHED
    
    if battle.get('finished'):
        return JsonResponse({
            'success': False,
            'message': 'This Boss Battle has already finished.'
        }, status=400)
        
    #VERIFY CURRENT ROUND TOKEN
    
    if not round_token or round_token != battle.get('round_token'):
        return JsonResponse({
            'success': False,
            'message': 'This round has already been processed or has expired.'
        }, status=409)
        
    #GET CURRENT WORD
    
    words = battle.get('words', [])
    current_index = battle.get('current_index', 0)
    
    if current_index >= len(words):
        return JsonResponse({
            'success': False,
            'message': 'No more words available.'
        }, status=400)
        
    current_word = words[current_index]
    
    #CHECK SERVER-SIDE TIMEOUT (10s + 2s network grace)
    is_timeout = request.POST.get('timeout') == 'true'
    started_at = battle.get('round_started_at')

    if started_at and (timezone.now().timestamp() - started_at) > 12:
        is_timeout = True
    
    #VALIDATE STUDENT ANSWER
    student_answer = normalize_boss_word(
        request.POST.get('answer', '')
    )
    
    if not is_timeout and not student_answer:
        return JsonResponse({
            'success': False,
            'message': 'Please enter an answer.'
        }, status=400)
        
    correct_answer = current_word['answer']
    
    is_correct = (not is_timeout) and (student_answer == correct_answer)
    
    #APPLY DAMAGE
    
    if is_correct:
        battle['king_bee_lives'] -= 1
        battle['correct_answers'] += 1
        
        feedback = 'Correct! King Bee has lost one life!'
        
    else:
        battle['beenary_lives'] -= 1
        battle['incorrect_answers'] += 1
        
        if is_timeout:
            feedback = "Time's up! King Bee attacked Beenary!"
        else:
            feedback = 'Incorrect! King Bee has attacked Beenary!'
        
    #CHECK BATTLE RESULT
    king_bee_lives = battle['king_bee_lives']
    beenary_lives = battle['beenary_lives']
    
    battle_finished = False
    result = None
    
    if king_bee_lives <= 0:
        battle_finished = True
        result = 'victory'
        
    elif beenary_lives <= 0:
        battle_finished = True
        result = 'defeat'
        
    #ADVANCE ROUND
    battle['current_index'] += 1
    
    #CHECK SUDDEN DEATH
    
    if not battle_finished and battle['current_index'] >= len(words):
        if king_bee_lives == beenary_lives:
            battle['sudden_death'] = True
            
            used_answers = {
                word['answer'] for word in words
            }
            
            candidate_answers = set(used_answers)
            
            additional_words = Pista_Boss_Battle.objects.select_related(
                'palabra'
            ).all()
            
            candidates = []
            
            for record in additional_words:
                answer = normalize_boss_word(
                    record.palabra.significado
                )
                
                clue_easy = record.pista_facil.strip()
                clue_medium = record.pista_intermedia.strip()
                clue_hard = record.pista_dificil.strip()
                
                if not 3 <= len(answer) <= 10:
                    continue
                
                if not clue_easy or not clue_medium or not clue_hard:
                    continue
                
                if answer in candidate_answers:
                    continue
                
                candidate_answers.add(answer)
                
                candidates.append({
                    'codigo': record.palabra.codigo,
                    'answer': answer,
                    'display_answer': record.palabra.significado.strip(),
                    'clue_easy': clue_easy,
                    'clue_medium': clue_medium,
                    'clue_hard': clue_hard,
                })
                
            random.shuffle(candidates)
            
            next_word = None
            
            for candidate in candidates:
                options = generate_boss_battle_options(
                    correct_answer=candidate['answer'],
                    correct_display=candidate['display_answer'],
                    excluded_answers=candidate_answers
                )
                
                if options is not None:
                    candidate['options'] = options
                    next_word = candidate
                    break
                
            if next_word:
                battle['words'].append(next_word)
                
            else:
                #No more words available
                battle_finished = True
                
                if king_bee_lives > beenary_lives:
                    result = 'victory'
                elif beenary_lives > king_bee_lives:
                    result = 'defeat'
                else:
                    result = 'draw'
                    
        else:
            battle_finished = True
            
            if beenary_lives > king_bee_lives:
                result = 'victory'
            else:
                result = 'defeat'
                
    #FINALIZE BATTLE
    
    xp_earned = 0
    total_xp = None
    
    if battle_finished:
        battle['finished'] = True
        battle['result'] = result
        
        #REGISTER EXPERIENCE POINTS
        
        if not battle.get('xp_awarded', False):
            if result == 'victory':
                xp_earned = 20
                
                alumno = request.user.alumno
                
                Alumno.objects.filter(
                    pk=alumno.pk
                ).update(
                    puntos_experiencia=F('puntos_experiencia') + xp_earned
                )
                
                alumno.refresh_from_db(
                    fields=['puntos_experiencia']
                )
                
                total_xp = alumno.puntos_experiencia
                
            else:
                alumno = request.user.alumno
                
                alumno.refresh_from_db(
                    fields=['puntos_experiencia']
                )
                
                total_xp = alumno.puntos_experiencia
                
            battle['xp_awarded'] = True
            
        else:
            
            alumno = request.user.alumno
            
            alumno.refresh_from_db(
                fields=['puntos_experiencia']
            )
            
            total_xp = alumno.puntos_experiencia
            
    #REGISTER BOSS BATTLE ACHIEVEMENTS
    
    if battle_finished:
        
        if result == 'victory':
            unlock_achievement(alumno, 'INS05')
            
            if battle['incorrect_answers'] == 0:
                unlock_achievement(alumno, 'INS09')
                
                unlock_achievement(alumno, 'INS11')
                
        if alumno.puntos_experiencia >= 100:
            unlock_achievement(alumno, 'INS14')
            
        if alumno.puntos_experiencia >= 500:
            unlock_achievement(alumno, 'INS16')
    
    #PREPARE RESPONSE 
    
    response_data = {
        'success': True,
        'correct': is_correct,
        'timeout': is_timeout,
        'feedback': feedback,
        'king_bee_lives': king_bee_lives,
        'beenary_lives': beenary_lives,
        'round': battle['current_index'] + 1,
        'sudden_death': battle['sudden_death'],
        'finished': battle_finished,
        'result': result,
        'xp_earned': xp_earned,
        'total_xp': total_xp,
    }
    
    if not battle_finished:
        next_index = battle['current_index']
        
        next_word = battle['words'][next_index]
        
        response_data['clue'] = get_boss_battle_clue(
            next_word,
            next_index
        )
        
        response_data['options'] = next_word['options']
        
    # GENERATE NEXT ROUND TOKEN AND RESET TIMER
    
    next_round_token = None
    
    if not battle_finished:
        next_round_token = secrets.token_urlsafe(16)
        response_data['round_token'] = next_round_token
        battle['round_started_at'] = timezone.now().timestamp()
        
    #SAVE PROCESSED ROUND
    battle['last_round_token'] = round_token
    battle['last_response'] = response_data
    battle['round_token'] = next_round_token
    
    #SAVE SESSION
    request.session['boss_battle'] = battle
    request.session.modified = True
        
    return JsonResponse(response_data)
    
@never_cache
@role_required('student')
def progress(request):
    alumno = request.user.alumno
    
    all_competitions = Competencia_Alumno.objects.filter(
        alumno=alumno
    ).select_related('competencia').order_by('-competencia__fecha', '-competencia__hora')
    
    recent_competitions = all_competitions[:3]
    competitions_count = all_competitions.count()
    
    total_xp = alumno.puntos_experiencia
    
    best_competition_score = all_competitions.aggregate(
        best_score=Max('puntos_obtenidos')
    )['best_score'] or 0
    
    insignias = Insignia.objects.all().order_by('clave')
    insignias_obtenidas = set(Alumno_Insignia.objects.filter(alumno=alumno).values_list('insignia_id', flat=True))
    
    achievements = []
    for insignia in insignias:
        achievements.append({
            'insignia': insignia,
            'obtenida': insignia.clave in insignias_obtenidas,
        })
        
    achievements_preview = sorted(achievements, key=lambda x: not x['obtenida'])[:4]
        
    context = {
        'achievements': achievements,
        'achievements_preview': achievements_preview,
        'achievements_earned': len(insignias_obtenidas),
        'achievements_total': insignias.count(),
        'total_xp': total_xp,
        'best_competition_score': best_competition_score,
        'competitions_count': competitions_count,
        'recent_competitions': recent_competitions,
        'all_competitions': all_competitions,
    }
    
    return render(request, 'student/progress.html', context)

@never_cache
@role_required('teacher')
def statistics(request):
    profesor = request.user.profesor
    
    group_code = request.GET.get('group', '')
    list_code = request.GET.get('list', '')
    period = request.GET.get('period', '7')
    
    groups = Grupo.objects.filter(
        profesor=profesor
    ).order_by('nombre')
    
    word_lists = Lista.objects.filter(
        profesor=profesor
    ).order_by('nombre')
    
    selected_group = None
    
    if group_code:
        selected_group = groups.filter(
            codigo=group_code
        ).first()
        
    if selected_group:
        students = Alumno.objects.filter(
            grupo_alumnos__grupo=selected_group
        ).select_related(
            'nivel',
            'carrera'
        ).distinct().order_by(
            'apellidoPaterno',
            'nombre_pila'
        )
    else:
        students = Alumno.objects.filter(
            grupo_alumnos__grupo__profesor=profesor
        ).select_related(
            'nivel',
            'carrera'
        ).distinct().order_by(
            'apellidoPaterno',
            'nombre_pila'
        )
        
    selected_list = None
    
    if list_code:
        selected_list = word_lists.filter(
            codigo=list_code
        ).first()
        
    today = timezone.localdate()
    
    if period == '30':
        start_date = today - timedelta(days=29)
    else:
        period = '7'
        start_date = today - timedelta(days=6)
        
    competitions = Competencia.objects.filter(
        profesor=profesor,
        fecha__gte=start_date,
        fecha__lte=today
    ).order_by('-fecha', '-hora')
    
    if selected_list:
        competitions = competitions.filter(
            lista_competencias__lista=selected_list
        ).distinct()
        
    total_students = students.count()
    total_groups = groups.count()
    total_competitions = Competencia.objects.filter(
        profesor=profesor
    ).count()
    total_word_lists = word_lists.count()
    
    xp_statistics = students.aggregate(
        total_xp=Sum('puntos_experiencia'),
        average_xp=Avg('puntos_experiencia')
    )
    
    total_xp = xp_statistics['total_xp'] or 0
    
    average_xp = round(
        xp_statistics['average_xp'] or 0,
        1
    )
    
    top_students = students.order_by(
        '-puntos_experiencia',
        'apellidoPaterno',
        'nombre_pila'
    )[:5]
    
    student_groups = {}
    
    group_relations = Grupo_Alumno.objects.filter(
        alumno__in=students,
        grupo__in=groups
    ).select_related(
        'alumno',
        'grupo'
    ).order_by(
        'grupo__nombre'
    )
    
    for relation in group_relations:
        matricula = relation.alumno_id
        
        if matricula not in student_groups:
            student_groups[matricula] = []
            
        student_groups[matricula].append(
            relation.grupo.nombre
        )
        
    for student in students:
        student.teacher_groups = student_groups.get(
            student.matricula,
            []
        )
    
    word_list_data = []
    
    for word_list in word_lists:
        if selected_list and word_list.codigo != selected_list.codigo:
            continue
        
        total_words = Lista_Palabra.objects.filter(
            lista=word_list
        ).count()
        
        word_list_data.append({
            'lista': word_list,
            'total_words': total_words,
        })
        
    competitions_by_date = {}
    
    for competition in competitions:
        date_key = competition.fecha
        
        competitions_by_date[date_key] = (
            competitions_by_date.get(date_key, 0) + 1
        )
        
    competition_chart = []
    current_date = start_date
    
    while current_date <= today:
        competition_chart.append({
            'date': current_date,
            'count': competitions_by_date.get(current_date, 0),
        })
        
        current_date += timedelta(days=1)
        
    context = {
        'groups': groups,
        'word_lists': word_lists,
        'selected_group': selected_group,
        'selected_list': selected_list,
        'selected_period': period,
        'students': students,
        'total_students': total_students,
        'total_groups': total_groups,
        'total_competitions': total_competitions,
        'total_word_lists': total_word_lists,
        'total_xp': total_xp,
        'average_xp': average_xp,
        'top_students': top_students,
        'word_list_data': word_list_data,
        'competitions': competitions,
        'competition_chart': competition_chart,
    }
    
    return render(
        request, 
        'teacher/statistics.html',
        context
    )

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
    alumno = request.user.alumno
    
    if request.method == 'POST':
        first_name = request.POST.get('first_name', '').strip()
        last_name = request.POST.get('last_name', '').strip()
        email = request.POST.get('email', '').strip()
        password = request.POST.get('password', '').strip()
        
        if first_name:
            request.user.nombre_pila = first_name
        if last_name:
            parts = last_name.split(' ', 1)
            request.user.apellidoPaterno = parts[0]
            if len(parts) > 1:
                request.user.apellidoMaterno = parts[1]
            else:
                request.user.apellidoMaterno = ''
                
        if email:
            request.user.correo = email
            
        password_changed = False
        if password:
            request.user.set_password(password)
            password_changed = True
            
        request.user.save()
        
        if password_changed:
            update_session_auth_hash(request, request.user)
            
        if 'foto' in request.FILES:
            alumno.foto = request.FILES['foto']
            alumno.save()
            
        messages.success(request, 'Profile updated successfully.')
        
        return redirect('student_profile')
        
    return render(request, 'student/edit_student_profile.html')

@never_cache
@role_required('teacher')
def teacher_profile(request):
    return render(request, 'teacher/teacher_profile.html')

@login_required
def edit_teacher_profile(request):
    profesor = request.user.profesor
    
    if request.method == 'POST':
        # Guardar imagen recibida
        if 'foto' in request.FILES:
            profesor.foto = request.FILES['foto']
            profesor.save()
            
        # Actualizar campos de texto
        nombre = request.POST.get('first_name')
        if nombre:
            request.user.nombre_pila = nombre
            request.user.save()
            
        return redirect('teacher_profile')

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
        .order_by('-average_score')[:5]
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
        
    recent_activities = Bitacora_Administrador.objects.select_related(
        'usuario'
    ).order_by(
        '-fecha_generacion',
        '-hora_generacion'
    )[:5]
    
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
        'recent_activities': recent_activities,
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

        if action == 'add_teacher':
            teacher_code = request.POST.get('teacher_code', '').strip()
            first_name = request.POST.get('first_name', '').strip()
            last_name = request.POST.get('last_name', '').strip()
            second_last_name = request.POST.get('second_last_name', '').strip()
            email = request.POST.get('email', '').strip()
            phone = request.POST.get('phone', '').strip()
            password = request.POST.get('password', '')

            if Usuario.objects.filter(codigo=teacher_code).exists():
                messages.error(request, 'A user with this teacher code already exists.')
                return redirect('admin_teachers')

            if Usuario.objects.filter(correo=email).exists():
                messages.error(request, 'A user with this email already exists.')
                return redirect('admin_teachers')

            try:
                with transaction.atomic():
                    tipo_teacher = TipoUsuario.objects.get(clave='TUSR02')

                    usuario = Usuario.objects.create_user(
                        correo=email,
                        password=password,
                        codigo=teacher_code,
                        nombre_pila=first_name,
                        apellidoPaterno=last_name,
                        apellidoMaterno=second_last_name,
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

                messages.success(request, 'Teacher created successfully.')

            except Exception as e:
                messages.error(request, f'Error creating teacher: {str(e)}')

            return redirect('admin_teachers')

        elif action == 'edit_teacher':
            teacher_code = request.POST.get('teacher_id', '').strip()
            email = request.POST.get('email', '').strip()
            phone = request.POST.get('phone', '').strip()
            password = request.POST.get('password', '').strip()

            try:
                usuario = Usuario.objects.get(codigo=teacher_code)
            except Usuario.DoesNotExist:
                messages.error(request, 'Teacher not found.')
                return redirect('admin_teachers')

            if Usuario.objects.filter(correo=email).exclude(codigo=teacher_code).exists():
                messages.error(request, 'Another user already has this email.')
                return redirect('admin_teachers')

            try:
                with transaction.atomic():
                    usuario.correo = email
                    usuario.numero_telefono = phone

                    if password:
                        usuario.set_password(password)

                    usuario.save()

                messages.success(request, 'Teacher updated successfully.')

            except Exception as e:
                messages.error(request, f'Error updating teacher: {str(e)}')

            return redirect('admin_teachers')

        elif action == 'delete_teacher':
            teacher_code = request.POST.get('teacher_id', '').strip()

            try:
                usuario = Usuario.objects.get(codigo=teacher_code)
            except Usuario.DoesNotExist:
                messages.error(request, 'Teacher not found.')
                return redirect('admin_teachers')

            try:
                with transaction.atomic():
                    usuario.is_active = False
                    usuario.save()

                messages.success(request, 'Teacher deactivated successfully.')

            except Exception as e:
                messages.error(request, f'Error deactivating teacher: {str(e)}')

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
        teachers = teachers.filter(grupos__nombre=group_filter).distinct()

    if status_filter == 'ACTIVE':
        teachers = teachers.filter(usuario__is_active=True)
    elif status_filter == 'INACTIVE':
        teachers = teachers.filter(usuario__is_active=False)

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
            'first_name': teacher.nombre_pila,
            'last_name': teacher.apellidoPaterno,
            'second_last_name': teacher.apellidoMaterno or '',
            'email': teacher.usuario.correo,
            'phone': teacher.usuario.numero_telefono,
            'assigned_groups': assigned_groups,
            'groups_display': ', '.join(assigned_groups) if assigned_groups else 'No groups',
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
        'available_groups': available_groups,
    }

    return render(request, 'administrator/teachers.html', context)

@never_cache
@role_required('administrator')
def admin_users(request):
    search_query = request.GET.get('search', '').strip()
    role_filter = request.GET.get('role', 'ALL')
    group_filter = request.GET.get('group', 'ALL')
    status_filter = request.GET.get('status', 'ALL')

    if request.method == 'POST':
        action = request.POST.get('action')

        if action == 'add_user':
            user_code = request.POST.get('user_code', '').strip()
            first_name = request.POST.get('first_name', '').strip()
            last_name = request.POST.get('last_name', '').strip()
            second_last_name = request.POST.get('second_last_name', '').strip()
            email = request.POST.get('email', '').strip()
            phone = request.POST.get('phone', '').strip()
            password = request.POST.get('password', '').strip()
            role = request.POST.get('role', 'STUDENT')
            status = request.POST.get('status', 'ACTIVE')

            if Usuario.objects.filter(codigo=user_code).exists():
                messages.error(request, 'A user with this code already exists.')
                return redirect('admin_users')

            if Usuario.objects.filter(correo=email).exists():
                messages.error(request, 'A user with this email already exists.')
                return redirect('admin_users')

            try:
                with transaction.atomic():
                    if role == 'STUDENT':
                        level_code = request.POST.get('level')
                        career_code = request.POST.get('career')

                        tipo_student = TipoUsuario.objects.get(clave='TUSR01')
                        level = Nivel.objects.get(codigo=level_code)
                        career = Carrera.objects.get(clave=career_code)

                        usuario = Usuario.objects.create_user(
                            correo=email,
                            password=password,
                            codigo=user_code,
                            nombre_pila=first_name,
                            apellidoPaterno=last_name,
                            apellidoMaterno=second_last_name,
                            numero_telefono=phone,
                            tipo_usuario=tipo_student,
                            is_active=(status == 'ACTIVE'),
                            is_staff=False,
                        )

                        Alumno.objects.create(
                            matricula=user_code,
                            nombre_pila=first_name,
                            apellidoPaterno=last_name,
                            apellidoMaterno=second_last_name,
                            usuario=usuario,
                            nivel=level,
                            carrera=career,
                        )

                        messages.success(request, 'Student registered successfully.')

                    elif role == 'TEACHER':
                        tipo_teacher = TipoUsuario.objects.get(clave='TUSR02')

                        usuario = Usuario.objects.create_user(
                            correo=email,
                            password=password,
                            codigo=user_code,
                            nombre_pila=first_name,
                            apellidoPaterno=last_name,
                            apellidoMaterno=second_last_name,
                            numero_telefono=phone,
                            tipo_usuario=tipo_teacher,
                            is_active=(status == 'ACTIVE'),
                            is_staff=False,
                        )

                        Profesor.objects.create(
                            clave=user_code,
                            nombre_pila=first_name,
                            apellidoPaterno=last_name,
                            apellidoMaterno=second_last_name,
                            usuario=usuario,
                        )

                        messages.success(request, 'Teacher registered successfully.')

                    elif role == 'ADMIN':
                        tipo_admin = TipoUsuario.objects.get(clave='TUSR03')

                        usuario = Usuario.objects.create_user(
                            correo=email,
                            password=password,
                            codigo=user_code,
                            nombre_pila=first_name,
                            apellidoPaterno=last_name,
                            apellidoMaterno=second_last_name,
                            numero_telefono=phone,
                            tipo_usuario=tipo_admin,
                            is_active=(status == 'ACTIVE'),
                            is_staff=False,
                        )

                        Administrador.objects.create(
                            clave=user_code,
                            nombre_pila=first_name,
                            apellidoPaterno=last_name,
                            apellidoMaterno=second_last_name,
                            usuario=usuario,
                        )

                        messages.success(request, 'Administrator registered successfully.')

                    else:
                        messages.error(request, 'This role is not available yet.')

                    if role in ['STUDENT', 'TEACHER', 'ADMIN']:
                        number_bitacora = 1
                        while Bitacora_Administrador.objects.filter(
                            codigo=f'BITA{number_bitacora:02d}'
                        ).exists():
                            number_bitacora += 1

                        codigo_bitacora = f'BITA{number_bitacora:02d}'
                        now = timezone.localtime()

                        Bitacora_Administrador.objects.create(
                            codigo=codigo_bitacora,
                            fecha_generacion=now.date(),
                            hora_generacion=now.time(),
                            accion=f'Created a new user: {first_name} {last_name}.',
                            usuario=request.user
                        )

            except Exception as e:
                messages.error(request, f'Error registering user: {str(e)}')

            return redirect('admin_users')

        elif action == 'edit_user':
            user_code = request.POST.get('user_id', '').strip()
            email = request.POST.get('email', '').strip()
            phone = request.POST.get('phone', '').strip()
            password = request.POST.get('password', '').strip()
            role = request.POST.get('role', 'STUDENT')
            status = request.POST.get('status', 'ACTIVE')

            try:
                usuario = Usuario.objects.get(codigo=user_code)
            except Usuario.DoesNotExist:
                messages.error(request, 'User not found.')
                return redirect('admin_users')

            if Usuario.objects.filter(correo=email).exclude(codigo=user_code).exists():
                messages.error(request, 'Another user already has this email.')
                return redirect('admin_users')

            try:
                with transaction.atomic():
                    usuario.correo = email
                    usuario.numero_telefono = phone
                    usuario.is_active = (status == 'ACTIVE')

                    if password:
                        usuario.set_password(password)

                    role_map = {
                        'STUDENT': 'TUSR01',
                        'TEACHER': 'TUSR02',
                        'ADMIN': 'TUSR03',
                    }

                    if role in role_map:
                        usuario.tipo_usuario = TipoUsuario.objects.get(clave=role_map[role])

                    usuario.save()

                    if role == 'STUDENT':
                        level_code = request.POST.get('level', '').strip()
                        career_code = request.POST.get('career', '').strip()

                        try:
                            alumno = Alumno.objects.get(usuario=usuario)
                            if level_code:
                                alumno.nivel = Nivel.objects.get(codigo=level_code)
                            if career_code:
                                alumno.carrera = Carrera.objects.get(clave=career_code)
                            alumno.save()
                        except Alumno.DoesNotExist:
                            pass

                    number_bitacora = 1
                    while Bitacora_Administrador.objects.filter(
                        codigo=f'BITA{number_bitacora:02d}'
                    ).exists():
                        number_bitacora += 1

                    codigo_bitacora = f'BITA{number_bitacora:02d}'
                    now = timezone.localtime()

                    Bitacora_Administrador.objects.create(
                        codigo=codigo_bitacora,
                        fecha_generacion=now.date(),
                        hora_generacion=now.time(),
                        accion=f'Updated user: {usuario.nombre_pila} {usuario.apellidoPaterno}.',
                        usuario=request.user
                    )

                messages.success(request, 'User updated successfully.')

            except Exception as e:
                messages.error(request, f'Error updating user: {str(e)}')

            return redirect('admin_users')

        elif action == 'delete_user':
            user_code = request.POST.get('user_id', '').strip()

            try:
                usuario = Usuario.objects.get(codigo=user_code)
            except Usuario.DoesNotExist:
                messages.error(request, 'User not found.')
                return redirect('admin_users')

            try:
                with transaction.atomic():
                    usuario.is_active = False
                    usuario.save()

                    number_bitacora = 1
                    while Bitacora_Administrador.objects.filter(
                        codigo=f'BITA{number_bitacora:02d}'
                    ).exists():
                        number_bitacora += 1

                    codigo_bitacora = f'BITA{number_bitacora:02d}'
                    now = timezone.localtime()

                    Bitacora_Administrador.objects.create(
                        codigo=codigo_bitacora,
                        fecha_generacion=now.date(),
                        hora_generacion=now.time(),
                        accion=f'Deactivated user: {usuario.nombre_pila} {usuario.apellidoPaterno}.',
                        usuario=request.user
                    )

                messages.success(request, 'User deactivated successfully.')

            except Exception as e:
                messages.error(request, f'Error deactivating user: {str(e)}')

            return redirect('admin_users')

    users = Usuario.objects.select_related(
        'tipo_usuario'
    ).prefetch_related(
        'alumno__grupo_alumnos__grupo',
        'profesor__grupos',
        'administrador'
    )

    if search_query:
        users = users.filter(
            Q(nombre_pila__icontains=search_query) |
            Q(apellidoPaterno__icontains=search_query) |
            Q(apellidoMaterno__icontains=search_query) |
            Q(correo__icontains=search_query)
        )

    if role_filter == 'STUDENT':
        users = users.filter(tipo_usuario__clave='TUSR01')
    elif role_filter == 'TEACHER':
        users = users.filter(tipo_usuario__clave='TUSR02')
    elif role_filter == 'ADMIN':
        users = users.filter(tipo_usuario__clave='TUSR03')

    if status_filter == 'ACTIVE':
        users = users.filter(is_active=True)
    elif status_filter == 'INACTIVE':
        users = users.filter(is_active=False)

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
        foto_url = None

        if role == 'STUDENT':
            try:
                for membership in user.alumno.grupo_alumnos.all():
                    groups.append(membership.grupo.nombre)
                if user.alumno.foto:
                    foto_url = user.alumno.foto.url
            except Alumno.DoesNotExist:
                pass

        elif role == 'TEACHER':
            try:
                for group in user.profesor.grupos.all():
                    groups.append(group.nombre)
                if user.profesor.foto:
                    foto_url = user.profesor.foto.url
            except Profesor.DoesNotExist:
                pass

        elif role == 'ADMIN':
            try:
                if hasattr(user, 'administrador') and user.administrador.foto:
                    foto_url = user.administrador.foto.url
            except Exception:
                pass

        group_display = ', '.join(groups) if groups else 'N/A'

        level = 'N/A'
        career_code = ''
        if role == 'STUDENT':
            try:
                level = user.alumno.nivel.codigo
                career_code = user.alumno.carrera.clave
            except Alumno.DoesNotExist:
                pass

        users_data.append({
            'id': user.codigo,
            'full_name': full_name,
            'first_name': user.nombre_pila,
            'last_name': user.apellidoPaterno,
            'second_last_name': user.apellidoMaterno or '',
            'email': user.correo,
            'phone': user.numero_telefono,
            'role': role,
            'group': group_display,
            'level': level,
            'career': career_code,
            'status': 'ACTIVE' if user.is_active else 'INACTIVE',
            'date_joined': 'N/A',
            'foto_url': foto_url,
        })

    available_groups = (
        Grupo.objects
        .values_list('nombre', flat=True)
        .distinct()
        .order_by('nombre')
    )

    available_levels = Nivel.objects.order_by('codigo')
    available_careers = Carrera.objects.order_by('nombre')

    context = {
        'users': users_data,
        'total_count': len(users_data),
        'search_query': search_query,
        'role_filter': role_filter,
        'group_filter': group_filter,
        'status_filter': status_filter,
        'available_groups': available_groups,
        'available_levels': available_levels,
        'available_careers': available_careers,
    }

    return render(request, 'administrator/users.html', context)

@never_cache
@role_required('administrator')
def admin_academy(request):
    carreras = Carrera.objects.all().order_by('clave')
    
    careers = []
    
    for carrera in carreras:
        grupos = Grupo.objects.filter(
            grupo_carreras__carrera=carrera
        ).distinct()
        
        students_count = Grupo_Alumno.objects.filter(
            grupo__in=grupos
        ).count()
        
        careers.append({
            'code': carrera.clave,
            'name': carrera.nombre,
            'status': 'ACTIVE',
            'groups_count': grupos.count(),
            'students_count': students_count,
        })
                
    niveles = Nivel.objects.all().order_by('codigo')
    
    levels = []
    
    for nivel in niveles:
        grupos = (
            Grupo.objects
            .filter(
                grupo_alumnos__alumno__nivel=nivel
            )
            .distinct()
        )
        
        levels.append({
            'code': nivel.codigo,
            'name': nivel.descripcion,
            'groups_count': grupos.count(),
        })
        
    grupos = (
        Grupo.objects
        .select_related('profesor')
        .prefetch_related(
            'grupo_alumnos__alumno__nivel',
            'grupo_carreras__carrera'
        )
        .order_by('nombre')
    )
    
    groups = []
    
    for grupo in grupos:
        teacher = grupo.profesor
        
        teacher_name = (
            f"{teacher.nombre_pila} "
            f"{teacher.apellidoPaterno} "
            f"{teacher.apellidoMaterno or ''}"
        ).strip()
        
        grupo_carrera = (
            Grupo_Carrera.objects
            .filter(grupo=grupo)
            .select_related('carrera')
            .first()
        )
        
        career_name = (
            grupo_carrera.carrera.nombre
            if grupo_carrera
            else 'Not assigned'
        )
        
        nivel = (
            Nivel.objects
            .filter(
                alumnos__grupo_alumnos__grupo=grupo
            )
            .first()
        )
        
        level_code = (
            nivel.codigo
            if nivel
            else 'Not assigned'
        )
        
        groups.append({
            'name': grupo.nombre,
            'career': career_name,
            'teacher': teacher_name,
            'level': level_code,
            'students_count': grupo.grupo_alumnos.count(),
            'status': 'ACTIVE',
        })
        
    profesores = Profesor.objects.all().order_by(
        'nombre_pila',
        'apellidoPaterno'
    )
    
    available_teachers = []
    
    for profesor in profesores:
        teacher_name = (
            f"{profesor.nombre_pila} "
            f"{profesor.apellidoPaterno} "
            f"{profesor.apellidoMaterno or ''}"
        ).strip()
        
        available_teachers.append(teacher_name)
    
    return render(
        request, 
        'administrator/academy.html',
        {
            'active_tab': 'careers',
            'careers': careers,
            'groups': groups,
            'levels': levels,
            'available_teachers': available_teachers,
        }
    )

@never_cache
@role_required('administrator')
def admin_backups(request):
    administrador = request.user.administrador

    if request.method == 'POST':
        action = request.POST.get('action')
        description = ' '.join(request.POST.get('description', '').split())[:200]

        # ---------- UPLOAD EXISTING BACKUP ----------
        if action == 'submit_backup':
            uploaded_file = request.FILES.get('backup_file')

            if not uploaded_file:
                messages.error(request, 'Please select an SQL backup file.')
                return redirect('admin_backups')

            if not uploaded_file.name.lower().endswith('.sql'):
                messages.error(request, 'Only SQL backup files are allowed.')
                return redirect('admin_backups')

            max_size = 50 * 1024 * 1024

            if uploaded_file.size > max_size:
                messages.error(request, 'The backup file cannot exceed 50 MB.')
                return redirect('admin_backups')

            head = uploaded_file.read(8192)
            uploaded_file.seek(0)

            if not looks_like_sql(head):
                messages.error(
                    request,
                    'The file does not look like a valid SQL dump '
                    '(empty, wrong encoding or not SQL).'
                )
                return redirect('admin_backups')

            backup_dir = os.path.join(settings.BASE_DIR, 'backups')
            os.makedirs(backup_dir, exist_ok=True)

            now = timezone.localtime()

            number = 1
            while Copia_Seguridad.objects.filter(
                codigo=f'COP{number:02d}'
            ).exists():
                number += 1

            codigo = f'COP{number:02d}'
            filename = f'{codigo}_uploaded.sql'
            backup_path = os.path.join(backup_dir, filename)

            file_created = False

            try:
                with open(backup_path, 'xb') as backup_file:
                    file_created = True

                    for chunk in uploaded_file.chunks():
                        backup_file.write(chunk)

                file_size = os.path.getsize(backup_path)
                size_text = format_size(file_size)

                datos = (
                    f'Filename: {filename}\n'
                    f'Size: {size_text}\n'
                    f'Type: Uploaded\n'
                    f'Description: {description or "No description"}'
                )

                Copia_Seguridad.objects.create(
                    codigo=codigo,
                    nombre=filename,
                    fecha=now.date(),
                    hora=now.time(),
                    datos=datos,
                    administrador=administrador
                )

                messages.success(request, 'Backup file uploaded successfully.')

            except Exception:
                logger.exception('Backup upload failed')
                if file_created and os.path.exists(backup_path):
                    os.remove(backup_path)

                messages.error(
                    request,
                    'An error occurred while uploading the backup file.'
                )

            return redirect('admin_backups')

        # ---------- CREATE BACKUP ----------
        if action != 'create_backup':
            messages.error(request, 'Invalid action.')
            return redirect('admin_backups')

        backup_type = 'Manual'
        include_media = request.POST.get('include_media') == 'on'
        include_logs = request.POST.get('include_logs') == 'on'
        use_zip = include_media or include_logs

        backup_dir = os.path.join(settings.BASE_DIR, 'backups')
        os.makedirs(backup_dir, exist_ok=True)

        now = timezone.localtime()
        stamp = now.strftime("%Y-%m-%d_%H-%M-%S")

        dump_path = os.path.join(backup_dir, f'backup_{stamp}.sql')
        filename = f'backup_{stamp}.zip' if use_zip else f'backup_{stamp}.sql'
        backup_path = os.path.join(backup_dir, filename)

        mysqldump_path = settings.MYSQLDUMP_PATH

        if not os.path.isfile(mysqldump_path):
            messages.error(
                request,
                'mysqldump was not found. Set the MYSQLDUMP_PATH variable in your .env file.'
            )
            return redirect('admin_backups')

        db_name = settings.DATABASES['default']['NAME']

        command = [
            mysqldump_path,
            '--host=localhost',
            '--port=3306',
            '--user=root',
            '--default-character-set=utf8mb4',
            '--single-transaction',
            '--routines',
            '--triggers',
            f'--ignore-table={db_name}.copia_seguridad',
            db_name
        ]

        try:
            with open(dump_path, 'wb') as dump_file:
                result = subprocess.run(
                    command,
                    stdout=dump_file,
                    stderr=subprocess.PIPE,
                    timeout=300
                )

            if result.returncode != 0:
                error_text = result.stderr.decode('utf-8', errors='replace').strip()
                logger.error('mysqldump failed: %s', error_text)
                last_line = error_text.splitlines()[-1][:200] if error_text else 'Unknown error'
                messages.error(
                    request,
                    f'The database backup could not be created. MySQL reported: {last_line}'
                )
                if os.path.exists(dump_path):
                    os.remove(dump_path)
                return redirect('admin_backups')

            includes = ['Database']

            if use_zip:
                with zipfile.ZipFile(backup_path, 'w', zipfile.ZIP_DEFLATED) as zf:
                    zf.write(dump_path, 'database.sql')
                    if include_media:
                        add_folder_to_zip(zf, settings.MEDIA_ROOT, 'media')
                        includes.append('Media')
                    if include_logs:
                        add_folder_to_zip(zf, settings.LOGS_DIR, 'logs')
                        includes.append('Logs')
                os.remove(dump_path)

            size_text = format_size(os.path.getsize(backup_path))

            number = 1
            while Copia_Seguridad.objects.filter(
                codigo=f'COP{number:02d}'
            ).exists():
                number += 1

            codigo = f'COP{number:02d}'

            datos = (
                f'Filename: {filename}\n'
                f'Size: {size_text}\n'
                f'Type: {backup_type}\n'
                f'Includes: {", ".join(includes)}\n'
                f'Description: {description or "No description"}'
            )

            Copia_Seguridad.objects.create(
                codigo=codigo,
                nombre=filename,
                fecha=now.date(),
                hora=now.time(),
                datos=datos,
                administrador=administrador
            )
            messages.success(request, 'Database backup created successfully.')

        except Exception:
            logger.exception('Backup creation failed')
            for path in (dump_path, backup_path):
                if os.path.exists(path):
                    os.remove(path)

            messages.error(
                request,
                'An error occurred while creating the database backup.'
            )

        return redirect('admin_backups')


    # ---------- LIST (GET) ----------
    backups = Copia_Seguridad.objects.filter(
        administrador=administrador
    ).order_by('-fecha', '-hora')

    total_backups = backups.count()
    last_backup = backups.first()

    if last_backup:
        last_backup_date = (
            f'{last_backup.fecha.strftime("%b %d, %Y")} '
            f'{last_backup.hora.strftime("%I:%M %p")}'
        )
    else:
        last_backup_date = 'No backups'

    for backup in backups:
        info = parse_backup_datos(backup.datos)
        backup.size_display = info['size']
        backup.type_display = info['type']

    context = {
        'backups': backups,
        'total_backups': total_backups,
        'last_backup_date': last_backup_date,
        'frequency': 'Manual',
    }

    return render(request, 'administrator/backups.html', context)
    
@never_cache
@role_required('administrator')
def admin_backup_download(request, codigo):
    administrador = request.user.administrador
    
    backup = get_object_or_404(
        Copia_Seguridad,
        codigo=codigo,
        administrador=administrador
    )
    backup_path = os.path.join(
        settings.BASE_DIR,
        'backups',
        backup.nombre
    )
    if not os.path.isfile(backup_path):
        messages.error(
            request,
            'The backup file could not be found in system storage.'
        )
        return redirect('admin_backups')
    
    return FileResponse(
        open(backup_path, 'rb'),
        as_attachment=True,
        filename=backup.nombre
    )
    
@never_cache
@role_required('administrator')
def admin_backup_delete(request, codigo):
    administrador = request.user.administrador
    
    if request.method != 'POST':
        return redirect('admin_backups')
    
    backup = get_object_or_404(
        Copia_Seguridad,
        codigo=codigo,
        administrador=administrador
    )
    backup_path = os.path.join(
        settings.BASE_DIR,
        'backups',
        backup.nombre
    )
    if os.path.isfile(backup_path):
        os.remove(backup_path)
    
    backup.delete()
    
    messages.success(
        request,
        'Backup deleted successfully.'
    )
    return redirect('admin_backups')

@never_cache
@role_required('administrator')
def admin_backup_restore(request, codigo):
    administrador = request.user.administrador

    if request.method != 'POST':
        return redirect('admin_backups')

    backup = get_object_or_404(
        Copia_Seguridad,
        codigo=codigo,
        administrador=administrador
    )
    backup_dir = os.path.join(settings.BASE_DIR, 'backups')
    backup_path = os.path.join(backup_dir, backup.nombre)

    if not os.path.isfile(backup_path):
        messages.error(request, 'The selected backup file could not be found.')
        return redirect('admin_backups')

    mysql_path = settings.MYSQL_PATH

    if not os.path.isfile(mysql_path):
        messages.error(
            request,
            'mysql was not found. Set the MYSQL_PATH variable in your .env file.'
        )
        return redirect('admin_backups')

    is_zip = backup.nombre.lower().endswith('.zip')
    temp_sql = None
    sql_path = backup_path

    try:
        if is_zip:
            if not zipfile.is_zipfile(backup_path):
                messages.error(request, 'The backup file is not a valid ZIP archive.')
                return redirect('admin_backups')

            with zipfile.ZipFile(backup_path) as zf:
                if 'database.sql' not in zf.namelist():
                    messages.error(request, 'The ZIP backup does not contain database.sql.')
                    return redirect('admin_backups')

                temp_sql = os.path.join(backup_dir, f'_restore_{codigo}.sql')
                with zf.open('database.sql') as src, open(temp_sql, 'wb') as dst:
                    shutil.copyfileobj(src, dst)

            sql_path = temp_sql

        with open(sql_path, 'rb') as f:
            head = f.read(8192)

        if not looks_like_sql(head):
            messages.error(
                request,
                'The backup file is empty or is not a valid SQL dump. Restore cancelled.'
            )
            return redirect('admin_backups')

        command = [
            mysql_path,
            '--host=localhost',
            '--port=3306',
            '--user=root',
            '--default-character-set=utf8mb4',
            settings.DATABASES['default']['NAME']
        ]

        with open(sql_path, 'rb') as sql_file:
            result = subprocess.run(
                command,
                stdin=sql_file,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                timeout=600
            )

        if result.returncode != 0:
            error_text = result.stderr.decode('utf-8', errors='replace').strip()
            logger.error('Restore failed: %s', error_text)
            last_line = error_text.splitlines()[-1][:200] if error_text else 'Unknown error'
            messages.error(
                request,
                f'The database could not be restored. MySQL reported: {last_line}'
            )
            return redirect('admin_backups')

        # Restore media files only when the ZIP includes them
        if is_zip:
            media_root = os.path.abspath(str(settings.MEDIA_ROOT))
            with zipfile.ZipFile(backup_path) as zf:
                for member in zf.namelist():
                    if not member.startswith('media/') or member.endswith('/'):
                        continue
                    target = os.path.abspath(os.path.join(media_root, member[len('media/'):]))
                    if not target.startswith(media_root + os.sep):
                        continue  # ignores unsafe paths
                    os.makedirs(os.path.dirname(target), exist_ok=True)
                    with zf.open(member) as src, open(target, 'wb') as dst:
                        shutil.copyfileobj(src, dst)

        messages.success(request, 'Database restored successfully.')

    except subprocess.TimeoutExpired:
        messages.error(request, 'The restore took too long and was cancelled.')
    except Exception:
        logger.exception('Restore exception')
        messages.error(request, 'An error occurred while restoring the database.')
    finally:
        if temp_sql and os.path.exists(temp_sql):
            os.remove(temp_sql)

    return redirect('admin_backups')

@never_cache
@role_required('administrator')
def admin_profile(request):
    admin = get_object_or_404(
        Administrador.objects.select_related('usuario'),
        usuario=request.user
    )
    
    return render(
        request, 
        'administrator/admin_profile.html',
        {
            'admin': admin
        }
    )

@never_cache
@role_required('student')
def group_view(request, group_id):
    grupo = get_object_or_404(
        Grupo.objects.select_related(
            'profesor__usuario'
        ),
        codigo=group_id
    )
    
    classmates = (
        Alumno.objects
        .filter(grupo_alumnos__grupo=grupo)
        .select_related('usuario')
        .order_by('apellidoPaterno', 'nombre_pila')
    )
    
    lista_palabras = (
        Lista_Palabra.objects
        .filter(lista__lista_grupos__grupo=grupo)
        .select_related(
            'palabra',
            'palabra__categoria'
        )
        .distinct()
    )
    
    teacher = grupo.profesor
    
    teacher_name = (
        f"{teacher.nombre_pila} "
        f"{teacher.apellidoPaterno} "
        f"{teacher.apellidoMaterno or ''}"
    ).strip()
    
    teacher_email = teacher.usuario.correo
    
    words = []
    
    for item in lista_palabras:
        palabra = item.palabra
        
        words.append({
            'word': palabra.significado,
            'meaning': palabra.definicion,
            'pronunciation': palabra.pronunciacion,
            'audio': palabra.audio,
            'image': palabra.imagen.url if palabra.imagen else None,
        })
        
    if not words and not request.session.get("mascot_msg"):
        say(
            request,
            "Your vocabulary is waiting!",
            "There are no words assigned to this group yet. Check back later and ask your teacher about upcoming Word Lists!"
        )
    
    return render(
        request, 
        'student/group_view.html',
        {
            'group': grupo,
            'teacher_name': teacher_name,
            'teacher_email': teacher_email,
            'classmates': classmates,
            'words': words,
        }
    )

@never_cache
@role_required('student')
def leave_group(request, group_id):
    alumno = request.user.alumno
    
    grupo = get_object_or_404(
        Grupo,
        codigo=group_id
    )
    
    if request.method == 'POST':
        membership = Grupo_Alumno.objects.filter(
            grupo=grupo,
            alumno=alumno
        ).first()
        
        if membership:
            membership.delete()
            messages.success(
                request,
                f'You have left "{grupo.nombre}" successfully.'
            )
            
            say(
                request,
                "A new chapter bee-gins!",
                "You have left this group. Remember, you can always join another classroom using your teacher's Group Code!"
            )
            
        else:
            messages.error(
                request,
                'You are not a member of this group.'
            )
            
        return redirect('student_groups')
    
@never_cache
@role_required('student')
def mini_games_view(request):
    alumno = request.user.alumno
    
    grupos = Grupo_Alumno.objects.filter(
        alumno=alumno
    ).values_list(
        'grupo',
        flat=True
    )
    listas = Lista_Grupo.objects.filter(
        grupo__in=grupos
    ).values_list(
        'lista',
        flat=True
    )
    palabras = Palabra.objects.filter(
        lista_palabras__lista__in=listas
    ).distinct().order_by('codigo')
    
    vocabulary = []
    
    for palabra in palabras:
        vocabulary.append({
            'word': palabra.significado.upper(),
            'meaning': palabra.definicion,
            'example': palabra.ejemplo,
            'image': palabra.imagen.url if palabra.imagen else '',
            'audio': palabra.audio.url if palabra.audio else '',
            'category': palabra.categoria.nombre,
            'level': palabra.nivel.codigo,
        })
        
    memory_words = Palabra.objects.filter(
        imagen__isnull=False
    ).exclude(
        imagen=''
    )
    
    memory_vocabulary = []
    
    for palabra in memory_words:
        memory_vocabulary.append({
            'word': palabra.significado.upper(),
            'image': palabra.imagen.url,
        })
        
    memory_difficulties = list(
        Dificultad_Juego.objects.filter(
            juego='J04'
        ).select_related(
            'dificultad'
        ).values(
            'dificultad__clave',
            'dificultad__nombre',
            'dificultad__descripcion'
        )
    )
        
    context = {
        'vocabulary': vocabulary,
        'memory_vocabulary': memory_vocabulary,
        'memory_difficulties': memory_difficulties,
    }
    
    return render(
        request, 
        'student/mini_games.html',
        context
    )
    
@never_cache
@role_required('student')
def student_competitions_view(request, competition_code):
    
    competencia = get_object_or_404(
        Competencia,
        codigo=competition_code
    )
    
    alumno = get_object_or_404(
        Alumno,
        usuario=request.user
    )
    
    participacion, created = Competencia_Alumno.objects.get_or_create(
        competencia=competencia,
        alumno=alumno,
        defaults={
            'puntos_obtenidos': 0,
            'palabras_correctas': 0,
            'palabras_incorrectas': 0,
        }
    )
    
    beehives = list(range(1, 61))
    
    es_spelling_bee = False
    
    if competencia.tipo == 'GENERAL':
        palabras_qs = (
            Palabra.objects.all()
            .select_related('categoria', 'nivel')
            .order_by('codigo')
        )
    else:
        relacion = Lista_Competencia.objects.filter(
            competencia=competencia
        ).select_related('lista').first()
        
        if relacion and relacion.lista:
            es_spelling_bee = relacion.lista.es_spelling_bee
            palabras_qs = (
                Palabra.objects.filter(
                    lista_palabras__lista=relacion.lista
                )
                .select_related('categoria', 'nivel')
                .distinct()
                .order_by('codigo')
            )
        else:
            palabras_qs = Palabra.objects.none()
    
    words_by_category = {
        'CAT11': [], 
        'CAT12': [], 
        'CAT13': [], 
        'CAT14': [], 
        'CAT15': [], 
        'CAT16': [], 
        'CAT17': [], 
        'SUDDEN_DEATH': [],
    }
    
    length_to_cat = {
        6: 'CAT11',
        7: 'CAT12',
        8: 'CAT13',
        9: 'CAT14',
        10: 'CAT15',
        11: 'CAT16',
        12: 'CAT17',
    }
    
    for palabra in palabras_qs:
        if palabra.significado:
            num_letras = len([char for char in palabra.significado if char.isalpha()])
            cat_key = length_to_cat.get(num_letras)
            
            if num_letras == 13 and es_spelling_bee:
                cat_key = 'SUDDEN_DEATH'
            
            if cat_key and cat_key in words_by_category:
                words_by_category[cat_key].append({
                    'texto': palabra.significado,
                    'definicion': palabra.definicion,
                    'ejemplo': palabra.ejemplo,
                    'pronunciacion': palabra.pronunciacion,
                    'categoria': cat_key,
                    'letras': f'{num_letras} Letters',
                    'nivel': palabra.nivel.codigo if palabra.nivel else '',
                })
    
    context = {
        'competencia': competencia,
        'beehives': beehives,
        'words_by_category': json.dumps(words_by_category),
    }
    return render(request, 'student/competitions_selecting.html', context)

@never_cache
@role_required('administrator')
def edit_admin_profile(request):
    admin = get_object_or_404(
        Administrador.objects.select_related('usuario'),
        usuario=request.user
    )
    
    if request.method == 'POST':
        first_name = request.POST.get('first_name', '').strip()
        last_name = request.POST.get('last_name', '').strip()
        email = request.POST.get('email', '').strip()
        password = request.POST.get('password', '').strip()
        
        if first_name:
            admin.nombre_pila = first_name
            admin.usuario.nombre_pila = first_name
            
        if last_name:
            parts = last_name.split(' ', 1)
            admin.apellidoPaterno = parts[0]
            admin.usuario.apellidoPaterno = parts[0]
            
            if len(parts) > 1:
                admin.apellidoMaterno = parts[1]
                admin.usuario.apellidoMaterno = parts[1]
            else:
                admin.apellidoMaterno = ''
                admin.usuario.apellidoMaterno = ''
                
        if email:
            admin.usuario.correo = email
            
        password_changed = False
        if password:  
            admin.usuario.set_password(password)
            password_changed = True
            
        if 'foto' in request.FILES:
            admin.foto = request.FILES['foto']
            
        admin.save()
        admin.usuario.save()
        
        if password_changed:
            update_session_auth_hash(request, admin.usuario)
        
        messages.success(
            request,
            'Your profile has been updated successfully.'
        )
        
        return redirect('admin_profile')
    
    return render(
        request, 
        'administrator/edit_admin_profile.html',
        {
            'admin': admin
        }
    )
    
@never_cache
@role_required('student')
def student_practice_english(request):
    return render(request, 'student/practice_your_english.html')

@never_cache
@role_required('student')
def practice_spelling(request):
    
    if request.method == 'POST':
        round_token = request.POST.get('round_token')
        session_token = request.session.get('ps_round_token')
        
        if not round_token or round_token != session_token:
            return JsonResponse(
                {
                    'success': False,
                    'message': 'Invalid or expired game session.'
                },
                status=400
            )
            
        del request.session['ps_round_token']
        
        try:
            errors = int(request.POST.get('errors', 0))
        except (TypeError, ValueError):
            errors = 0
            
        errors = max(0, errors)
        
        xp_earned = max(0, 20 - errors)
        
        alumno = request.user.alumno
        
        Alumno.objects.filter(pk=alumno.pk).update(
            puntos_experiencia=F('puntos_experiencia') + xp_earned
        )
        
        alumno.refresh_from_db(
            fields=['puntos_experiencia']
        )
        
        unlock_achievement(alumno, 'INS06')
        
        if errors == 0:
            unlock_achievement(alumno, 'INS10')
            
        if alumno.puntos_experiencia >= 100:
            unlock_achievement(alumno, 'INS14')
            
        if alumno.puntos_experiencia >= 500:
            unlock_achievement(alumno, 'INS16')
        
        return JsonResponse(
            {
                'success': True,
                'errors': errors,
                'xp_earned': xp_earned,
                'total_xp': alumno.puntos_experiencia
            }
        )
        
    round_token = secrets.token_urlsafe(32)
    
    request.session['ps_round_token'] = round_token
    
    return render(
        request, 
        'student/practice_spelling.html',
        {
            'round_token': round_token,
        }
    )

@never_cache
@role_required('student')
def student_match_words(request):
    
    if request.method == 'POST':
        
        round_token = request.POST.get('round_token')
        session_token = request.session.get('mw_round_token')
        
        if not round_token or round_token != session_token:
            return JsonResponse(
                {
                    'success': False,
                    'message': 'Invalid or expired game session.'
                },
                status=400
            )
            
        del request.session['mw_round_token']
        
        try:
            errors = int(request.POST.get('errors', 0))
        except (TypeError, ValueError):
            errors = 0
            
        errors = max(0, errors)
        
        xp_earned = max(0, 20 - errors)
        
        alumno = request.user.alumno
        
        Alumno.objects.filter(pk=alumno.pk).update(
            puntos_experiencia=F('puntos_experiencia') + xp_earned
        )
        
        alumno.refresh_from_db(
            fields=['puntos_experiencia']
        )
        
        unlock_achievement(alumno, 'INS07')
        
        if errors == 0:
            unlock_achievement(alumno, 'INS10')
        
        if alumno.puntos_experiencia >= 100:
            unlock_achievement(alumno, 'INS14')
            
        if alumno.puntos_experiencia >= 500:
            unlock_achievement(alumno, 'INS16')
        
        return JsonResponse(
            {
                'success': True,
                'errors': errors,
                'xp_earned': xp_earned,
                'total_xp': alumno.puntos_experiencia
            }
        )
        
    categories = list(
        Categoria.objects
        .filter(
            codigo__in=[
                'CAT01', 'CAT02', 'CAT03', 'CAT04', 'CAT05', 'CAT06', 'CAT07', 'CAT08',
                'CAT09', 'CAT10', 'CAT11', 'CAT12', 'CAT13', 'CAT14', 'CAT15', 'CAT16',
                'CAT17',
            ]
        )
    )
    
    random.shuffle(categories)
    selected_categories = categories[:5]
    
    words = []
    
    for category in selected_categories:
        category_words = list(
            Palabra.objects
            .filter(categoria=category)
        )
        
        if category_words:
            words.append(
                random.choice(category_words)
            )
            
    random.shuffle(words)
    
    round_token = secrets.token_urlsafe(32)
    
    request.session['mw_round_token'] = round_token
    
    return render(
        request,
        'student/match_words.html',
        {
            'words': words,
            'categories': selected_categories,
            'round_token': round_token,
        }
    )

@never_cache
@role_required('student')
def practice_speaking(request):
    
    if request.method == 'POST':
        round_token = request.POST.get('round_token')
        session_token = request.session.get('pk_round_token')
        
        if not round_token or round_token != session_token:
            return JsonResponse(
                {
                    'success': False,
                    'message': 'Invalid or expired game session.'
                },
                status=400
            )
            
        del request.session['pk_round_token']
        
        try:
            errors = int(request.POST.get('errors', 0))
        except (TypeError, ValueError):
            errors = 0
            
        errors = max(0, errors)
        
        xp_earned = max(0, 20 - errors)
        
        alumno = request.user.alumno
        
        Alumno.objects.filter(pk=alumno.pk).update(
            puntos_experiencia=F('puntos_experiencia') + xp_earned
        )
        
        alumno.refresh_from_db(
            fields=['puntos_experiencia']
        )
        
        unlock_achievement(alumno, 'INS08')
        
        if errors == 0:
            unlock_achievement(alumno, 'INS10')
            
        if alumno.puntos_experiencia >= 100:
            unlock_achievement(alumno, 'INS14')
            
        if alumno.puntos_experiencia >= 500:
            unlock_achievement(alumno, 'INS16')
        
        return JsonResponse(
            {
                'success': True,
                'errors': errors,
                'xp_earned': xp_earned,
                'total_xp': alumno.puntos_experiencia
            }
        )
        
    round_token = secrets.token_urlsafe(32)
    
    pk_words = [
        'Photography', 'Mountain', 'Loyalty', 'Umbrella', 'Journey', 'Kitchen', 'Freedom',
        'Spotlight', 'Whisper', 'Adventure',
    ]
    
    request.session['pk_round_token'] = round_token
    request.session['pk_expected_words'] = pk_words
    request.session['pk_counted_words'] = []
    
    return render(
        request, 
        'student/practice_speaking.html', 
        {
            'round_token': round_token,
            'pk_words': pk_words,
        }
    )

@never_cache
@role_required('teacher')
def teacher_competition_results(request, pk):
    competition = get_object_or_404(
        Competencia,
        pk=pk,
        profesor=request.user.profesor,
    )
    
    if competition.estado != 'Finished':
        messages.info(
            request,
            "Results will be available when the competition finishes."
        )
        return redirect("teacher_competitions")
    
    participaciones = (
        Competencia_Alumno.objects
        .filter(competencia=competition)
        .select_related(
            'alumno',
            'alumno__usuario',
            'grupo',
        )
        .order_by(
            '-palabras_correctas',
            'alumno__apellidoPaterno',
            'alumno__apellidoMaterno',
            'alumno__nombre_pila',
            'alumno_id',
        )
    )
    
    grupos_disponibles = (
        Grupo.objects
        .filter(profesor=competition.profesor)
        .order_by('nombre')
    )
    
    alumnos_grupos = (
        Grupo_Alumno.objects
        .filter(grupo__profesor=competition.profesor)
        .select_related(
            'alumno',
            'alumno__usuario',
            'grupo',
        )
        .order_by(
            'grupo__nombre',
            'alumno__apellidoPaterno',
            'alumno__apellidoMaterno',
            'alumno__nombre_pila',
        )
    )
    
    alumnos_candidatos = []
    
    for relacion in alumnos_grupos:
        alumno = relacion.alumno
        
        alumnos_candidatos.append({
            'enrollment': alumno.matricula,
            'first_name': alumno.nombre_pila,
            'last_name': (
                f"{alumno.apellidoPaterno} "
                f"{alumno.apellidoMaterno or ''}"
            ).strip(),
            'email': alumno.usuario.correo,
            'group': relacion.grupo.nombre,
            'group_code': relacion.grupo.codigo,
        })
            
    participantes_ids = set(
        Competencia_Alumno.objects
        .filter(competencia=competition)
        .values_list('alumno_id', flat=True)
    )
    
    if request.method == 'POST':
        action = request.POST.get('action')
        
        if action == 'add_participants':
            grupo_codigo = request.POST.get('grupo', '').strip()
            
            grupo_seleccionado = get_object_or_404(
                Grupo,
                codigo=grupo_codigo,
                profesor=competition.profesor,
            )
            
            matriculas_seleccionadas = set(
                request.POST.getlist('participantes')
            )
            
            matriculas_validas = set(
                Grupo_Alumno.objects
                .filter(
                    grupo=grupo_seleccionado,
                    grupo__profesor=competition.profesor,
                )
                .values_list('alumno_id', flat=True)
            )
            
            matriculas_seleccionadas &= matriculas_validas
            
            agregados = 0
            
            for matricula in matriculas_seleccionadas:
                _, creado = Competencia_Alumno.objects.get_or_create(
                    competencia=competition,
                    alumno_id=matricula,
                    defaults={
                        'grupo': grupo_seleccionado,
                    },
                )
                
                if creado:
                    agregados += 1
                    
            if agregados:
                messages.success(
                    request,
                    f'{agregados} participant(s) added successfully.'
                )
            else:
                messages.info(
                    request,
                    'No new participants were added.'
                )
                
            return redirect(
                'teacher_competition_results',
                pk=competition.pk,
            )
        
        elif action == 'save_results':
            matricula = request.POST.get('matricula', '').strip()

            participacion = get_object_or_404(
                Competencia_Alumno,
                competencia=competition,
                alumno_id=matricula,
            )

            correctas_raw = request.POST.get(
                f'correct_{matricula}', ''
            ).strip()

            incorrectas_raw = request.POST.get(
                f'incorrect_{matricula}', ''
            ).strip()

            puntos_raw = request.POST.get(
                f'points_{matricula}', ''
            ).strip()

            if not correctas_raw or not incorrectas_raw or not puntos_raw:
                messages.error(
                    request,
                    'Please complete all result fields.'
                )
                return redirect(
                    'teacher_competition_results',
                    pk=competition.pk,
                )

            try:
                correctas = int(correctas_raw)
                incorrectas = int(incorrectas_raw)
                puntos = int(puntos_raw)
            except ValueError:
                messages.error(
                    request,
                    'Results must be whole numbers.'
                )
                return redirect(
                    'teacher_competition_results',
                    pk=competition.pk,
                )

            if correctas < 0 or incorrectas < 0 or puntos < 0:
                messages.error(
                    request,
                    'Results cannot be negative.'
                )
                return redirect(
                    'teacher_competition_results',
                    pk=competition.pk,
                )

            participacion.palabras_correctas = correctas
            participacion.palabras_incorrectas = incorrectas
            participacion.puntos_obtenidos = puntos

            participacion.save(update_fields=[
                'palabras_correctas',
                'palabras_incorrectas',
                'puntos_obtenidos',
            ])
            
            participaciones_calificadas = (
                Competencia_Alumno.objects
                .filter(
                    competencia=competition,
                    palabras_correctas__isnull=False,
                )
                .select_related('alumno')
                .order_by(
                    '-palabras_correctas',
                    'alumno__apellidoPaterno',
                    'alumno__apellidoMaterno',
                    'alumno__nombre_pila',
                    'alumno_id',
                )
            )
            
            for posicion, participante in enumerate(
                participaciones_calificadas,
                start=1
            ):
                participante.posicion = posicion
                participante.save(update_fields=['posicion'])
                
            Competencia_Alumno.objects.filter(
                competencia=competition,
                palabras_correctas__isnull=True,
            ).update(posicion=None)
            
            notificacion = (
                Notificacion.objects
                .filter(
                    alumno=participacion.alumno,
                    tipo='COMPETITION_RESULT',
                    competencia=competition,
                )
                .order_by('id')
                .first()
            )
            
            titulo = f"Results Available: {competition.nombre}"
            
            mensaje = (
                f"Your results for {competition.nombre} are available. "
                f"Correct: {correctas}, Incorrect: {incorrectas}, "
                f"Points: {puntos}."
            )
            
            if notificacion:
                notificacion.titulo = titulo
                notificacion.mensaje = mensaje
                notificacion.leida = False
                notificacion.save(update_fields=[
                    'titulo',
                    'mensaje',
                    'leida',
                ])
            else:
                Notificacion.objects.create(
                    alumno=participacion.alumno,
                    tipo='COMPETITION_RESULT',
                    titulo=titulo,
                    mensaje=mensaje,
                    competencia=competition,
                    leida=False,
                )

            messages.success(
                request,
                'Student results saved successfully.'
            )

            return redirect(
                'teacher_competition_results',
                pk=competition.pk,
            )
    
    results = []
    
    for participacion in participaciones:
        alumno = participacion.alumno
        
        group_name = (
            participacion.grupo.nombre
            if participacion.grupo
            else '-'
        )
        
        results.append({
            'enrollment': alumno.matricula,
            'first_name': alumno.nombre_pila,
            'last_name': (
                f"{alumno.apellidoPaterno} "
                f"{alumno.apellidoMaterno or ''}"
            ).strip(),
            'email': alumno.usuario.correo,
            'group': group_name,
            'correct': participacion.palabras_correctas,
            'incorrect': participacion.palabras_incorrectas,
            'points': participacion.puntos_obtenidos,
        })
        
    total_words = 0
    
    if results and results[0]['correct'] is not None:
        if results[0]['incorrect'] is not None:
            total_words = (
                results[0]['correct'] +
                results[0]['incorrect']
            )

    return render(
        request, 
        "teacher/competitions_results.html",
        {
            'competition': competition,
            'results': results,
            'total_words': total_words,
            'alumnos_candidatos': alumnos_candidatos,
            'participantes_ids': participantes_ids,
            'grupos_disponibles': grupos_disponibles,
        }
    )

@never_cache
@role_required('teacher')
@require_POST
def teacher_start_competition(request, codigo):
    competition = get_object_or_404(
        Competencia, 
        codigo=codigo,
        profesor=request.user.profesor
    )
    
    if competition.estado == 'Finished':
        messages.error(
            request,
            'A finished competition cannot be started again.'
        )
        return redirect('teacher_competitions')
    
    if competition.estado == 'Active':
        messages.info(
            request,
            f'{competition.nombre} is already Active.'
        )
        return redirect('teacher_competitions')
    
    competition.estado = 'Active'
    competition.save(update_fields=['estado'])
    
    messages.success(request, f"Competition {competition.nombre} is now Active!")
    return redirect('teacher_competitions')

@never_cache
@role_required('teacher')
@require_POST
def teacher_finish_competition(request, codigo):
    competition = get_object_or_404(
        Competencia,
        codigo=codigo,
        profesor=request.user.profesor
    )
    
    if competition.estado != 'Active':
        messages.error(
            request,
            'Only active competitions can be finished.'
        )
        return redirect('teacher_competitions')
    
    competition.estado = 'Finished'
    competition.save(update_fields=['estado'])
    
    messages.success(
        request,
        f'Competition {competition.nombre} has been finished.'
    )
    
    return redirect('teacher_competitions')

@never_cache
@role_required('teacher')
def teacher_edit_competition(request, codigo):
    competition = get_object_or_404(
        Competencia, 
        codigo=codigo,
        profesor=request.user.profesor
    )
    if request.method == 'POST':
        competition.nombre = request.POST.get('nombre')
        competition.fecha = request.POST.get('fecha')
        competition.hora = request.POST.get('hora')
        competition.save()
        messages.success(request, "Competition updated successfully.")
    return redirect('teacher_competitions')

@never_cache
@role_required('teacher')
def edit_group(request, group_id):
    profesor = request.user.profesor
    grupo = get_object_or_404(Grupo, codigo=group_id, profesor=profesor)

    if request.method == 'POST':
        nombre = request.POST.get('nombre', '').strip()
        nivel = request.POST.get('nivel', '').strip()

        if nombre:
            grupo.nombre = nombre
            if nivel:
                grupo.ciclo = nivel
                
            grupo.save()

            now = timezone.localtime()
            number_bitacora = Bitacora_Profesor.objects.count() + 1
            
            Bitacora_Profesor.objects.create(
                codigo=f'BITP{number_bitacora:02d}',
                fecha_generacion=now.date(),
                hora_generacion=now.time(),
                accion=f'Updated group details: {nombre}.',
                profesor=profesor
            )

            messages.success(request, f'Group "{nombre}" updated successfully.')
            
        else:
            messages.error(
                request,
                'Group name cannot be empty.'
            )
    return redirect('teacher_groups')

@never_cache
@role_required('teacher')
def delete_group(request, group_id):
    profesor = request.user.profesor
    grupo = get_object_or_404(Grupo, codigo=group_id, profesor=profesor)

    if request.method == 'POST':
        nombre_grupo = grupo.nombre

        grupo.delete()

        now = timezone.localtime()
        number_bitacora = Bitacora_Profesor.objects.count() + 1
        Bitacora_Profesor.objects.create(
            codigo=f'BITP{number_bitacora:02d}',
            fecha_generacion=now.date(),
            hora_generacion=now.time(),
            accion=f'Delete group: {nombre_grupo}',
            profesor=profesor
        )

        messages.success(request, f'Group "{nombre_grupo}" was deleted successfully.')

    return redirect('teacher_groups')

@never_cache
@role_required('student')
def student_competition_results(request, codigo):
    alumno = request.user.alumno
    competition = get_object_or_404(Competencia, codigo=codigo)

    participacion = Competencia_Alumno.objects.filter(
        alumno=alumno,
        competencia=competition
    ).first()
    
    total_puntos = (
        participacion.puntos_obtenidos
        if participacion and participacion.puntos_obtenidos is not None
        else 0
    )
    
    palabras_correctas = (
        participacion.palabras_correctas
        if participacion and participacion.palabras_correctas is not None
        else 0
    )
    
    palabras_incorrectas = (
        participacion.palabras_incorrectas
        if participacion and participacion.palabras_incorrectas is not None
        else 0
    )
    
    total_palabras = palabras_correctas + palabras_incorrectas
    
    context = {
        'competition': competition,
        'total_palabras': total_palabras,
        'palabras_correctas': palabras_correctas,
        'palabras_incorrectas': palabras_incorrectas,
        'total_puntos': total_puntos,
        'posicion': (
            participacion.posicion
            if participacion
            else None
        ),
    }
    
    posicion = context['posicion']
    
    if not request.session.get("mascot_msg"):
        resultados_registrados = (
            participacion is not None
            and participacion.palabras_correctas is not None
            and participacion.palabras_incorrectas is not None
        )
        
        if not resultados_registrados:
            say(
                request,
                "No Results to Show Yet!",
                "Your competition results are not available yet. Keep practicing and get ready for your next spelling challenge!"
            )
            
        else:
            accuracy = (
                (palabras_correctas / total_palabras) * 100
                if total_palabras > 0
                else 0
            )
            
            if posicion == 1:
                if accuracy >= 80:
                    say(
                        request,
                        "You're the Bee-st of the Best!",
                        "Amazing work! You earned 1st place with outstanding accuracy. Keep shining and showing off your spelling skills!!"
                    )
                else:
                    say(
                        request,
                        "A Bee-autiful Victory!",
                        "You earned 1st place! That's an amazing achievement. Keep practicing to make even more of your words count!"
                    )
            elif posicion in (2, 3):
                if accuracy >= 80:
                    say(
                        request,
                        "What a Bee-autiful Achievement!",
                        "Congratulations! You earned a place among the top three with great accuracy. Your hard work is paying off. Keep buzzing like that!"
                    )
                else:
                    say(
                        request,
                        "You Made the Podium!",
                        "Congratulations on reaching the top three! Keep practicing and improving your spelling accuracy. You can do even better!"
                    )
            elif accuracy >= 80:
                say(
                    request,
                    "You're Buzzing with Progress!",
                    "You spelled at least a 80 percentage of the words correctly! That's something to be proud of. Keep up the excellent work!"
                )
            else:
                say(
                    request,
                    "Every Bee-ginning Counts!",
                    "Every competition is a chance to learn and improve. Be proud of your effort, learn from your mistakes and keep practicing!"
                )
    
    return render(request, 'student/student_competition_results.html', context)

def password_reset_request(request):
    """Paso 1: Solicitar correo electrónico"""
    if request.method == 'POST':
        email = request.POST.get('email', '').strip()
        usuario = Usuario.objects.filter(correo=email, is_active=True).first()
        
        if usuario:
            # Generar PIN de 6 dígitos
            pin = f"{random.randint(100000, 999999)}"
            
            # Guardar en la sesión con tiempo límite (10 minutos)
            request.session['reset_email'] = email
            request.session['reset_pin'] = pin
            request.session['reset_pin_expires'] = (timezone.now() + timedelta(minutes=10)).timestamp()
            
            subject = "Password Reset Code - Spell-Challenge"
            message = f"Hello {usuario.nombre_pila},\n\nYour verification code to reset your password is: {pin}\n\nThis code will expire in 10 minutes.\n\nIf you did not request this, please ignore this email."
            send_mail(
                subject,
                message,
                settings.DEFAULT_FROM_EMAIL,
                [email],  
                fail_silently=False,
            )
            
            messages.success(request, f"A 6-digit verification code has been sent to {email}.")
            return redirect('password_reset_code')
        else:
            messages.error(request, "No active account found with this email address.")
            
    return render(request, 'users/password_reset_request.html')


def password_reset_code(request):
    """Paso 2: Validar PIN de 6 dígitos"""
    email = request.session.get('reset_email')
    stored_pin = request.session.get('reset_pin')
    expires_at = request.session.get('reset_pin_expires')
    
    if not email or not stored_pin:
        messages.error(request, "Session expired or invalid request. Please try again.")
        return redirect('password_reset_request')
        
    if request.method == 'POST':
        pin_entered = request.POST.get('pin', '').strip()
        
        # Validar expiración (10 min)
        if timezone.now().timestamp() > expires_at:
            messages.error(request, "The verification code has expired. Please request a new one.")
            return redirect('password_reset_request')
            
        if pin_entered == stored_pin:
            request.session['reset_pin_verified'] = True
            return redirect('password_reset_confirm')
        else:
            messages.error(request, "Invalid verification code. Please check and try again.")
            
    return render(request, 'users/password_reset_code.html', {'email': email})


def password_reset_confirm(request):
    """Paso 3: Establecer nueva contraseña"""
    email = request.session.get('reset_email')
    verified = request.session.get('reset_pin_verified')
    
    if not email or not verified:
        messages.error(request, "Unauthorized access. Please restart the reset process.")
        return redirect('password_reset_request')
        
    if request.method == 'POST':
        password = request.POST.get('password', '').strip()
        confirm_password = request.POST.get('confirm_password', '').strip()
        
        if len(password) < 6:
            messages.error(request, "Password must be at least 6 characters long.")
        elif password != confirm_password:
            messages.error(request, "Passwords do not match.")
        else:
            usuario = Usuario.objects.get(correo=email)
            usuario.set_password(password)
            usuario.save()
            
            del request.session['reset_email']
            del request.session['reset_pin']
            del request.session['reset_pin_expires']
            del request.session['reset_pin_verified']
            
            messages.success(request, "Password updated successfully! You can now log in.")
            return redirect('login')
            
    return render(request, 'users/password_reset_confirm.html')