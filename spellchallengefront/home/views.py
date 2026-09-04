from django.shortcuts import render

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