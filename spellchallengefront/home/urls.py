from django.urls import path
from . import views

urlpatterns = [
    path('', views.landing, name='landing'),
    path('login/', views.login, name='login'),
    path('choose-role/', views.choose_role, name='choose_role'),
    path('signup/student/', views.signup_student, name='signup_student'),
    path('signup/teacher/', views.signup_teacher, name='signup_teacher'),
    path('dashboard/', views.dashboard, name='dashboard'),
]
