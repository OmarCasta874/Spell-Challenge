from django.shortcuts import render, redirect
from django.contrib.auth import authenticate, login as auth_login, logout
from django.views.decorators.http import require_POST

# Create your views here.

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

def dashboard(request):
    return render(request, 'teacher/dashboard.html')

def my_groups(request):
    return render(request, 'teacher/my_groups.html')

def word_lists(request):
    return render(request, 'teacher/word_lists.html')

def student_home(request):
    return render(request, 'student/home.html')

def student_groups(request):
    return render(request, 'student/my_groups_student.html')

def teacher_competitions(request):
    return render(request, 'teacher/competitions.html')

def student_competitions(request):
    return render(request, 'student/competitions.html')

def lesson1(request):
    return render(request, 'student/lesson1.html')

def practices(request):
    return render(request, 'student/practices.html')

def progress(request):
    return render(request, 'student/progress.html')

def statistics(request):
    return render(request, 'teacher/statistics.html')

def logout_view(request):
    logout(request)
    return redirect('login')

def student_profile(request):
    return render(request, 'student/student_profile.html')

def teacher_profile(request):
    return render(request, 'teacher/teacher_profile.html')

@require_POST
def custom_logout_view(request):
    logout(request)
    return redirect('login')