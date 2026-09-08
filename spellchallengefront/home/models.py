from django.db import models
from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin, BaseUserManager

# Create your models here.


# MODELOS DJANGO SPELL-CHALLENGE

class UsuarioManager(BaseUserManager):
    
    def create_user(self, correo, password=None, **extra_fields):
        if not correo:
            raise ValueError('El usuario debe tener un correo electrónico')
        
        correo = self.normalize_email(correo)
        
        usuario = self.model(
            correo=correo,
            **extra_fields
        )
        
        usuario.set_password(password)
        usuario.save(using=self._db)
        
        return usuario
    
    def create_superuser(self, correo, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('is_active', True)
        
        return self.create_user(
            correo,
            password,
            **extra_fields
        )

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
    
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    
    objects = UsuarioManager()
    
    USERNAME_FIELD = 'correo'
    REQUIRED_FIELDS = [
        'nombre_pila',
        'apellidoPaterno',
        'apellidoMaterno',
        'tipo_usuario'
    ]
    
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
    nombre = models.CharField(max_length=150)
    descripcion = models.TextField(blank=True, null=True)
    
    class Meta:
        db_table = 'carrera'
        
    def __str__(self):
        return self.nombre
    

#MODELO GRUPO
class Grupo(models.Model):
    codigo = models.AutoField(primary_key=True)
    
    nombre = models.CharField(max_length=100)
    fecha_creacion = models.DateField()
    ciclo = models.CharField(max_length=50)
    
    profesor = models.ForeignKey(
        Profesor,
        on_delete=models.PROTECT,
        related_name='profesores'
    )
    
    class Meta:
        db_table = 'grupo'
        
    def __str__(self):
        return self.nombre
    

#MODELO CATEGORIA
class Categoria(models.Model):
    codigo = models.AutoField(primary_key=True)
    nombre = models.CharField(max_length=100)
    
    class Meta:
        db_table = 'categoria'
        
    def __str__(self):
        return self.nombre
    

#MODELO NIVEL
class Nivel(models.Model):
    numero = models.AutoField(primary_key=True)
    descripcion = models.TextField(blank=True, null=True)
    
    class Meta:
        db_table = 'nivel'
        
    def __str__(self):
        return self.numero
    

#MODELO PALABRA
class Palabra(models.Model):
    codigo = models.AutoField(primary_key=True)
    
    texto = models.CharField(max_length=100)
    significado = models.CharField(max_length=100)
    pronunciacion = models.CharField(max_length=100)
    
    imagen = models.ImageField(
        upload_to='palabras/imagenes/',
        blank=True,
        null=True
    )
    
    audio = models.FileField(
        upload_to='palabras/audios',
        blank=True,
        null=True
    )
    
    nivel = models.ForeignKey(
        Nivel,
        on_delete=models.PROTECT,
        related_name='palabras'
    )
    
    categoria = models.ForeignKey(
        Categoria,
        on_delete=models.PROTECT,
        related_name='palabras'
    )
    
    class Meta:
        db_table = 'palabra'
        
    def __str__(self):
        return str(self.texto)
    

#MODELO LISTA
class Lista(models.Model):
    codigo = models.AutoField(primary_key=True)
    
    nombre = models.CharField(max_length=100)
    fecha_asignacion = models.DateField()
    fecha_limite = models.DateField()
    numero_letras = models.PositiveIntegerField()
    
    profesor = models.ForeignKey(
        Profesor,
        on_delete=models.PROTECT,
        related_name='listas'
    )
    
    class Meta:
        db_table = 'lista'
        
    def __str__(self):
        return self.nombre
    

#MODELO LISTA_PALABRA
class Lista_Palabra(models.Model):
    lista = models.ForeignKey(
        Lista,
        on_delete=models.CASCADE,
        related_name='lista_palabras'
    )
    
    palabra = models.ForeignKey(
        Palabra,
        on_delete=models.CASCADE,
        related_name='lista_palabras'
    )
    
    class Meta:
        db_table = 'lista_palabra'
        constraints = [
            models.UniqueConstraint(
                fields=['lista', 'palabra'],
                name='unique_lista_palabra'
            )
        ]

#MODELO LISTA_GRUPO
class Lista_Grupo(models.Model):
    lista = models.ForeignKey(
        Lista,
        on_delete=models.CASCADE,
        related_name='lista_grupos'
    )
    
    grupo = models.ForeignKey(
        Grupo,
        on_delete=models.CASCADE,
        related_name='lista_grupos'
    )
    
    class Meta:
        db_table = 'lista_grupo'
        constraints = [
            models.UniqueConstraint(
                fields=['lista', 'grupo'],
                name='unique_lista_grupo'
            )
        ]

#MODELO GRUPO_ALUMNO
class Grupo_Alumno(models.Model):
    grupo = models.ForeignKey(
        Grupo,
        on_delete=models.CASCADE,
        related_name='grupo_alumnos'
    )
    
    alumno = models.ForeignKey(
        Alumno,
        on_delete=models.CASCADE,
        related_name='grupo_alumnos'
    )
    
    class Meta:
        db_table = 'grupo_alumno'
        constraints = [
            models.UniqueConstraint(
                fields=['grupo', 'alumno'],
                name='unique_grupo_alumno'
            )
        ]

#MODELO PROCESO_LISTA
class Proceso_Lista(models.Model):
    lista = models.ForeignKey(
        Lista,
        on_delete=models.CASCADE,
        related_name='procesos'
    )
    
    alumno = models.ForeignKey(
        Alumno,
        on_delete=models.CASCADE,
        related_name='procesos_lista'
    )
    
    porcentaje_aciertos = models.DecimalField(
        max_digits=5,
        decimal_places=2,
        default=0
    )
    
    lista_desbloqueada = models.BooleanField(default=False)
    
    fecha_completado = models.DateField(
        blank=True,
        null=True
    )
    
    class Meta:
        db_table = 'proceso_lista'
        constraints = [
            models.UniqueConstraint(
                fields=['lista', 'alumno'],
                name='unique_proceso_lista'
            )
        ]

#MODELO JUEGO
class Juego(models.Model):
    clave = models.AutoField(primary_key=True)
    
    nombre = models.CharField(max_length=100)
    descripcion = models.TextField(blank=True, null=True)
    mecanica = models.TextField(blank=True, null=True)
    
    class Meta:
        db_table = 'juego'
        
    def __str__(self):
        return self.nombre

#MODELO DIFICULTAD
class Dificultad(models.Model):
    clave = models.AutoField(primary_key=True)
    
    nombre = models.CharField(max_length=50)
    descripcion = models.TextField(blank=True, null=True)
    
    class Meta:
        db_table = 'dificultad'
        
    def __str__(self):
        return self.nombre
    

#MODELO DIFICULTAD_JUEGO
class Dificultad_Juego(models.Model):
    juego = models.ForeignKey(
        Juego,
        on_delete=models.CASCADE,
        related_name='dificultades'
    )
    
    dificultad = models.ForeignKey(
        Dificultad,
        on_delete=models.CASCADE,
        related_name='juegos'
    )
    
    class Meta:
        db_table = 'dificultad_juego'
        constraints = [
            models.UniqueConstraint(
                fields=['juego', 'dificultad'],
                name='unique_juego_dificultad'
            )
        ]
    

#MODELO PRACTICA_SESION
class Practica_Sesion(models.Model):
    clave = models.AutoField(primary_key=True)
    
    fecha = models.DateField()
    duracion = models.DurationField()
    porcentaje_aciertos = models.DecimalField(
        max_digits=5,
        decimal_places=2,
        default=0
    )
    
    puntos_obtenidos = models.PositiveIntegerField(
        default=0
    )
    
    juego = models.ForeignKey(
        Juego,
        on_delete=models.PROTECT,
        related_name='practicas'
    )
    
    lista = models.ForeignKey(
        Lista,
        on_delete=models.PROTECT,
        related_name='practicas'
    )
    
    class Meta:
        db_table = 'practica_sesion'
        
    def __str__(self):
        return f"Práctica {self.clave}"
    

#MODELO ALUMNO_PRACTICA
class Alumno_Practica(models.Model):
    alumno = models.ForeignKey(
        Alumno,
        on_delete=models.CASCADE,
        related_name='practicas'
    )
    
    practica_sesion = models.ForeignKey(
        Practica_Sesion,
        on_delete=models.CASCADE,
        related_name='alumnos'
    )
    
    class Meta:
        db_table = 'alumno_practica'
        constraints = [
            models.UniqueConstraint(
                fields=['alumno', 'practica_sesion'],
                name='unique_alumno_practica'
            )
        ]

#MODELO INTENTO_PALABRA
class Intento_Palabra(models.Model):
    clave = models.AutoField(primary_key=True)
    
    acertado = models.BooleanField(default=False)
    
    tiempo_respuesta = models.DurationField(
        blank=True,
        null=True
    )
    
    numero_intentos = models.PositiveIntegerField(
        default=1
    )
    
    practica_sesion = models.ForeignKey(
        Practica_Sesion,
        on_delete=models.CASCADE,
        related_name='intentos'
    )
    
    palabra = models.ForeignKey(
        Palabra,
        on_delete=models.PROTECT,
        related_name='intentos'
    )
    
    class Meta:
        db_table = 'intento_palabra'
        
    def __str__(self):
        return f"Intento {self.clave}"
    

#MODELO RANGO
class Rango(models.Model):
    codigo = models.AutoField(primary_key=True)
    
    nombre = models.CharField(max_length=100)
    
    minimo = models.PositiveIntegerField()
    maximo = models.PositiveIntegerField()
    
    alumno = models.ForeignKey(
        Alumno,
        on_delete=models.PROTECT,
        related_name='rangos'
    )
    
    class Meta:
        db_table = 'rango'
        
    def __str__(self):
        return self.nombre
    
#MODELO TIPO_RANKING
class TipoRanking(models.Model):
    codigo = models.AutoField(primary_key=True)
    
    nombre = models.CharField(max_length=100)
    descripcion = models.TextField(blank=True, null=True)
    
    class Meta:
        db_table = 'tipo_ranking'
        
    def __str__(self):
        return self.nombre

#MODELO RANKING
class Ranking(models.Model):
    codigo = models.AutoField(primary_key=True)
    
    nombre = models.CharField(max_length=100)
    posicion = models.PositiveIntegerField()
    periodo = models.CharField(max_length=100)
    
    puntos = models.PositiveIntegerField(default=0)
    
    alumno = models.ForeignKey(
        Alumno,
        on_delete=models.CASCADE,
        related_name='rankings'
    )
    
    tipo_ranking = models.ForeignKey(
        TipoRanking,
        on_delete=models.PROTECT,
        related_name='rankings'
    )
    
    class Meta:
        db_table = 'ranking'
        
    def __str__(self):
        return f"{self.nombre} - {self.posicion}"
    

#MODELO INSIGNIA
class Insignia(models.Model):
    clave = models.AutoField(primary_key=True)
    
    nombre = models.CharField(max_length=100)
    descripcion = models.TextField(blank=True, null=True)
    criterio_obtencion = models.TextField(blank=True, null=True)
    
    class Meta:
        db_table = 'insignia'
        
    def __str__(self):
        return self.nombre

#MODELO ALUMNO_INSIGNIA
class Alumno_Insignia(models.Model):
    alumno = models.ForeignKey(
        Alumno,
        on_delete=models.CASCADE,
        related_name='insignias'
    )
    
    insignia = models.ForeignKey(
        Insignia,
        on_delete=models.CASCADE,
        related_name='alumnos'
    )
    
    fecha_obtenida = models.DateField()
    
    class Meta:
        db_table = 'alumno_insignia'
        constraints = [
            models.UniqueConstraint(
                fields=['alumno', 'insignia'],
                name='unique_alumno_insignia'
            )
        ]

#MODELO REPORTE
class Reporte(models.Model):
    codigo = models.AutoField(primary_key=True)
    
    fecha_generacion = models.DateField(
        auto_now_add=True
    )
    tipo_reporte = models.CharField(max_length=100)
    
    profesor = models.ForeignKey(
        Profesor,
        on_delete=models.PROTECT,
        related_name='reportes'
    )
    
    class Meta:
        db_table = 'reporte'
        
    def __str__(self):
        return f"{self.tipo_reporte} - {self.codigo}"
    