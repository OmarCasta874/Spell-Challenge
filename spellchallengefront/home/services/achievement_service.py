from django.db import transaction
from django.utils import timezone

from home.models import Alumno_Insignia, Insignia, Notificacion

@transaction.atomic
def unlock_achievement(alumno, insignia_clave):
    """
    Desbloquea una insignia para un estudiante y genera
    una notificación si es la primera vez que la obtiene.
    """
    
    insignia = Insignia.objects.get(clave=insignia_clave)
    
    relacion, creada = Alumno_Insignia.objects.get_or_create(
        alumno=alumno,
        insignia=insignia,
        defaults={
            'fecha_obtenida': timezone.localdate()
        }
    )
    
    if not creada:
        return False
    
    Notificacion.objects.create(
        alumno=alumno,
        tipo='ACHIEVEMENT',
        titulo=f'New Achievement: {insignia.nombre}',
        mensaje=(
            f'You earned the {insignia.nombre}',
            f'{insignia.descripcion}'
        ),
        insignia=insignia
    )
    
    return True