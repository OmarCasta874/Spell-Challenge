from django.shortcuts import render, redirect
from django.contrib.auth import logout

# Create your views here.

def landing(request):
    return render(request, 'base/landing.html')

def login(request):
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

def practices(request):
    return render(request, 'student/practices.html')

def logout_view(request):
    logout(request)
    return redirect('login')