from django.urls import path
from . import views

urlpatterns = [
    path('', views.landing, name='landing'),
    path('login/', views.login, name='login'),
    path('choose-role/', views.choose_role, name='choose_role'),
    path('signup/student/', views.signup_student, name='signup_student'),
    path('signup/teacher/', views.signup_teacher, name='signup_teacher'),
    path('dashboard/', views.dashboard, name='teacher_dashboard'),
    path('mygroups/', views.my_groups, name='teacher_groups'),
    path('word_lists/', views.word_lists, name='teacher_word_lists'),
    path('home/', views.student_home, name='student_home'),
    path('mygroups_student/', views.student_groups, name='student_groups'),
    path('practices/', views.practices, name='student_practices'),
    path('logout/', views.logout_view, name='logout'),
]
