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
    path('teacher_competitions/', views.teacher_competitions, name='teacher_competitions'),
    path('student_competitions/', views.student_competitions, name='student_competitions'),
    path('lesson_1/', views.lesson1, name='lesson_1'),
    path('student_progress/', views.progress, name='student_progress'),
    path('statistics/', views.statistics, name='statistics'),
    path('practices/', views.practices, name='student_practices'),
    path('student_profile', views.student_profile, name='student_profile'),
    path('teacher_profile', views.teacher_profile, name='teacher_profile'),
    path('logout/', views.logout_view, name='logout'),
    path('logout_ask/', views.custom_logout_view, name='logout_ask'),
]
