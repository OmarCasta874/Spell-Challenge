from django.db import models
from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin

# Create your models here.


# MODELOS DJANGO SPELL-CHALLENGE

#MODELO USUARIO
class Usuario(AbstractBaseUser, PermissionsMixin):
    codigo = models.AutoField(primary_key=True)
    
    nombre_pila = models.CharField(max_length=100)
    apellidoPaterno = models.CharField(max_length=100)
    apellidoMaterno = models.CharField(max_length=100)
    
    correo = models.EmailField(unique=True)
    numero_telefono = models.CharField(max_length=20, blank=True, null=True)
    
    tipo_usuario = models.ForeignKey(
        'TipoUsuario',
        on_delete=models.PROTECT,
        related_name='usuarios',
    )
    
    USERNAME_FIELD = 'correo'
    
    class Meta:
        db_table = 'usuario'
        
    def __str__(self):
        return self.correo
    

#MODELO TIPO_USUARIO    
class TipoUsuario(models.Model):
    clave = models.AutoField(primary_key=True)
    nombre = models.CharField(max_length=50)
    descripcion = models.TextField(blank=True, null=True)
    
    class Meta:
        db_table = 'tipo_usuario'
        
    def __str__(self):
        return self.nombre

#MODELO PROFESOR    
class Profesor(models.Model):
    clave = models.AutoField(primary_key=True)
    
    nombre_pila = models.CharField(max_length=100)
    apellidoPaterno = models.CharField(max_length=100)
    apellidoMaterno = models.CharField(max_length=100)
    
    usuario = models.OneToOneField(
        Usuario,
        on_delete=models.CASCADE,
        related_name='profesor'
    )
    
    class Meta:
        db_table = 'profesor'
        
    def __str__(self):
        return f"{self.nombre_pila} {self.apellidoPaterno}"
    
    
#MODELO ALUMNO    
class Alumno(models.Model):
    matricula = models.CharField(max_length=20, primary_key=True)
    
    nombre_pila = models.CharField(max_length=100)
    apellidoPaterno = models.CharField(max_length=100)
    apellidoMaterno = models.CharField(max_length=100)
    
    usuario = models.OneToOneField(
        Usuario,
        on_delete=models.CASCADE,
        related_name='alumno'
    )
    
    nivel = models.ForeignKey(
        'Nivel',
        on_delete=models.PROTECT,
        related_name='alumnos'
    )
    
    carrera = models.ForeignKey(
        'Carrera',
        on_delete=models.PROTECT,
        related_name='alumnos'
    )
    
    class Meta:
        db_table = 'alumno'
        
    def __str__(self):
        return f"{self.matricula} - {self.nombre_pila} {self.apellidoPaterno}"
    
#MODELO ADMINISTRADOR
class Administrador(models.Model):
    codigo = models.AutoField(primary_key=True)
    
    nombre = models.CharField(max_length=100)
    
    usuario = models.OneToOneField(
        Usuario,
        on_delete=models.CASCADE,
        related_name='administrador'
    )
    
    class Meta:
        db_table = 'administrador'
        
    def __str__(self):
        return self.nombre
    
    
#MODELO CARRERA
class Carrera(models.Model):
    clave = models.AutoField(primary_key=True)
    nombre = models.CharField(max_length=100)
    descripcion = models.CharField(blank=True, null=True)
    
    class Meta:
        db_table = 'carrera'
    

#MODELO GRUPO
class Grupo(models.Model):
    codigo = models.AutoField(primary_key=True)
    
    nombre = models.CharField(max_length=100)
    fecha_creacion = models.DateField(max_length=15)
    ciclo = models.CharField(max_length=50)
    
    profesor = models.ForeignKey(
        'Profesor',
        on_delete=models.PROTECT,
        related_name='profesores'
    )
    
    alumno = models.ForeignKey(
        'Alumno',
        on_delete=models.PROTECT,
        related_name='alumnos'
    )
    
    class Meta:
        db_table = 'grupo'

#MODELO CATEGORIA
class Categoria(models.Model):
    codigo = models.AutoField(primary_key=True)
    
    nombre = models.CharField(max_length=100)
    
    class Meta:
        db_table = 'categoria'

#MODELO NIVEL
class Nivel(models.Model):
    numero = models.AutoField(primary_key=True)
    
    descripcion = models.CharField(blank=True, null=True)
    
    class Meta:
        db_table = 'nivel'

#MODELO PALABRA
class Palabra(models.Model):
    codigo = models.AutoField(primary_key=True)
    
    significado = models.CharField(max_length=100)
    pronunciacion = models.CharField(max_length=100)
    
    nivel = models.ForeignKey(
        'Nivel',
        on_delete=models.PROTECT,
        related_name='niveles'
    )
    
    categoria = models.ForeignKey(
        'Categoria',
        on_delete=models.PROTECT,
        related_name='categorias'
    )
    
    class Meta:
        db_table = 'palabra'

#MODELO LISTA
class Lista(models.Model):
    codigo = models.AutoField(primary_key=True)
    
    nombre = models.CharField(max_length=100)
    fecha_asignacion = models.DateField(max_length=15)
    fecha_limite = models.DateField(max_length=15)
    numero_letras = models.IntegerField(max_length=5)
    
    profesor = models.ForeignKey(
        'Profesor',
        on_delete=models.PROTECT,
        related_name='listas'
    )
    
    class Meta:
        db_table = 'lista'

#MODELO LISTA_PALABRA
class Lista_Palabra(models.Model):
    
    class Meta:
        db_table = ''

#MODELO LISTA_GRUPO
class Lista_Grupo(models.Model):
    
    class Meta:
        db_table = 'lista_grupo'

#MODELO GRUPO_ALUMNO
class Grupo_Alumno(models.Model):
    
    class Meta:
        db_table = 'grupo_alumno'

#MODELO PROCESO_LISTA
class Proceso_Lista(models.Model):
    
    porcentaje_aciertos = models.IntegerField(max_length=10)
    lista_desbloqueada = models.CharField(max_length=50)
    fecha_completado = models.DateField(max_length=15)
    
    class Meta:
        db_table = 'proceso_lista'

#MODELO JUEGO
class Juego(models.Model):
    clave = models.AutoField(primary_key=True)
    
    nombre = models.CharField(max_length=100)
    descripcion = models.CharField(max_length=250)
    mecanica = models.CharField(max_length=100)
    
    class Meta:
        db_table = 'juego'

#MODELO DIFICULTAD
class Dificultad(models.Model):
    clave = models.AutoField(primary_key=True)
    
    nombre = models.CharField(max_length=100)
    descripcion = models.CharField(max_length=250)
    
    class Meta:
        db_table = 'dificultad'

#MODELO DIFICULTAD_JUEGO
class Dificultad_Juego(models.Model):
    
    class Meta:
        db_table = 'dificultad_juego'

#MODELO PRACTICA_SESION
class Practica_Sesion(models.Model):
    clave = models.AutoField(primary_key=True)
    
    fecha = models.DateField(max_length=100)
    duracion = models.CharField(max_length=100)
    porcentaje_acertivos = models.CharField(max_length=10)
    puntos_obtenidos = models.IntegerField(max_length=10)
    
    juego = models.ForeignKey(
        'Juego',
        on_delete=models.PROTECT,
        related_name='juegos'
    )
    
    class Meta:
        db_table = 'practica_sesion'

#MODELO ALUMNO_PRACTICA
class Alumno_Practica(models.Model):
    
    class Meta:
        db_table = 'alumno_practica'

#MODELO INTENTO_PALABRA
class Intento_Palabra(models.Model):
    clave = models.AutoField(primary_key=True)
    
    acertado = models.CharField(max_length=50)
    tiempo_respuesta = models.CharField(max_length=50)
    numero_intentos = models.IntegerField(max_length=50)
    
    practica_sesion = models.ForeignKey(
        'Practica_Sesion',
        on_delete=models.PROTECT,
        related_name='practicas_sesiones'
    )
    
    palabra = models.ForeignKey(
        'Palabra',
        on_delete=models.PROTECT,
        related_name='palabras'
    )
    
    class Meta:
        db_table = 'intento_palabra'

#MODELO RANGO
class Rango(models.Model):
    codigo = models.AutoField(primary_key=True)
    
    nombre = models.CharField(max_length=100)
    minimo = models.IntegerField(max_length=5)
    maximo = models.IntegerField(max_length=5)
    
    alumno = models.ForeignKey(
        'Alumno',
        on_delete=models.PROTECT,
        related_name='alumnos'
    )
    
    class Meta:
        db_table = 'rango'

#MODELO RANKING
class Ranking(models.Model):
    codigo = models.AutoField(primary_key=True)
    
    nombre = models.CharField(max_length=100)
    posicion = models.CharField(max_length=50)
    periodo = models.CharField(max_length=100)
    puntos = models.IntegerField(max_length=10)
    
    alumno = models.ForeignKey(
        'Alumno',
        on_delete=models.PROTECT,
        related_name='alumnos'
    )

#MODELO TIPO_RANKING
class Tipo_Ranking(models.Model):
    codigo = models.AutoField(primary_key=True)
    
    nombre = models.CharField(max_length=100)
    descripcion = models.CharField(max_length=250)
    
    ranking = models.ForeignKey(
        'Ranking',
        on_delete=models.PROTECT,
        related_name='rankings'
    )
    
    class Meta:
        db_table = 'tipo_ranking'

#MODELO INSIGNIA
class Insignia(models.Model):
    clave = models.AutoField(primary_key=True)
    
    nombre = models.CharField(max_length=100)
    descripcion = models.CharField(max_length=250)
    criterio_obtencion = models.CharField(max_length=100)
    
    class Meta:
        db_table = 'insignia'

#MODELO ALUMNO_INSIGNIA
class Alumno_Insignia(models.Model):
    
    fecha_obtenida = models.DateField(max_length=15)
    
    class Meta:
        db_table = 'alumno_insignia'

#MODELO REPORTE
class Reporte(models.Model):
    codigo = models.AutoField(primary_key=True)
    
    fecha_generacion = models.DateField(max_length=15)
    tipo_reporte = models.CharField(max_length=100)
    
    profesor = models.ForeignKey(
        'Profesor',
        on_delete=models.PROTECT,
        related_name='reportes'
    )
    
    class Meta:
        db_table = 'reporte'