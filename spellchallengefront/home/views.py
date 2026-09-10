from django.shortcuts import render, redirect
from django.contrib.auth import authenticate, login as auth_login, logout
from django.contrib.auth.decorators import login_required
from django.views.decorators.http import require_POST
from django.views.decorators.cache import never_cache
from functools import wraps

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
    return render(request, 'teacher/dashboard.html')

@never_cache
@role_required('teacher')
def my_groups(request):
    return render(request, 'teacher/my_groups.html')

@never_cache
@role_required('teacher')
def word_lists(request):
    return render(request, 'teacher/word_lists.html')

@never_cache
@role_required('student')
def student_home(request):
    return render(request, 'student/home.html')

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
@role_required('teacher')
def teacher_profile(request):
    return render(request, 'teacher/teacher_profile.html')

@require_POST
def custom_logout_view(request):
    logout(request)
    return redirect('login')