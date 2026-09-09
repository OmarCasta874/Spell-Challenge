from django.contrib import admin
from .models import Usuario

# Register your models here.

@admin.register(Usuario)
class UsuarioAdmin(admin.ModelAdmin):
    list_display = (
        'codigo',
        'correo',
        'nombre_pila',
        'apellidoPaterno',
        'apellidoMaterno',
        'tipo_usuario',
        'is_active',
        'is_staff',
    )
    
    list_display_links = (
        'codigo',
    )
    
    list_filter = (
        'tipo_usuario',
        'is_active',
        'is_staff',
    )
    
    search_fields = (
        'codigo',
        'correo',
        'nombre_pila',
        'apellidoPaterno',
        'apellidoMaterno',
    )