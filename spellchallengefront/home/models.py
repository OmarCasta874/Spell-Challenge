from django.db import models
from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin, BaseUserManager

# Create your models here.


# MODELOS DJANGO SPELL-CHALLENGE


class UsuarioManager(BaseUserManager):
    
    def create_user(self, correo, password=None, **extra_fields):
        if not correo:
            raise ValueError('El usuario debe tener un correo electrónico')
        
        correo = self.normalize_email(correo)
        
        tipo_usuario = extra_fields.get('tipo_usuario')
        
        if isinstance(tipo_usuario, str):
            tipo_usuario = TipoUsuario.objects.get(clave=tipo_usuario)
            extra_fields['tipo_usuario'] = tipo_usuario
        
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
        
        if extra_fields.get('is_staff') is not True:
            raise ValueError('El SuperUser debe tener is_staff=True. ')
        
        if extra_fields.get('is_superuser') is not True:
            raise ValueError('El SuperUser debe tener is_superuser=True.')
        
        return self.create_user(
            correo,
            password,
            **extra_fields
        )

#MODELO TIPO_USUARIO    
class TipoUsuario(models.Model):
    clave = models.CharField(
        max_length=10,
        primary_key=True
    )
    nombre = models.CharField(max_length=30)
    descripcion = models.CharField(max_length=100)
    
    class Meta:
        db_table = 'tipo_usuario'
        
    def __str__(self):
        return self.nombre

#MODELO USUARIO
class Usuario(AbstractBaseUser, PermissionsMixin):
    codigo = models.CharField(
        max_length=10,
        primary_key=True
    )
    
    nombre_pila = models.CharField(max_length=30)
    apellidoPaterno = models.CharField(
        max_length=30,
        db_column='apellPaterno'
    )
    apellidoMaterno = models.CharField(
        max_length=30,
        db_column='apellMaterno'
    )
    
    correo = models.EmailField(unique=True)
    numero_telefono = models.CharField(
        max_length=20, 
        db_column='telefono'
    )
    
    password = models.CharField(
        max_length=128,
        db_column='contraseña'
    )
    
    tipo_usuario = models.ForeignKey(
        TipoUsuario,
        on_delete=models.PROTECT,
        related_name='usuarios',
        db_column='tipo_usuario',
        to_field='clave'
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

#MODELO PROFESOR    
class Profesor(models.Model):
    clave = models.CharField(max_length=10, primary_key=True)
    nombre_pila = models.CharField(max_length=30)
    apellidoPaterno = models.CharField(
        max_length=100,
        db_column='apellPaterno'
    )
    apellidoMaterno = models.CharField(
        max_length=100,
        blank=True,
        null=True,
        db_column='apellMaterno'
    )
    usuario = models.OneToOneField(
        Usuario,
        on_delete=models.CASCADE,
        related_name='profesor',
        db_column='usuario',
        to_field='codigo'
    )

    class Meta:
        db_table = 'profesor'

    def __str__(self):
        return f"{self.nombre_pila} {self.apellidoPaterno}"
    
    
#MODELO ALUMNO    
class Alumno(models.Model):
    matricula = models.CharField(max_length=10, primary_key=True)
    nombre_pila = models.CharField(
        max_length=30,
        db_column='nombrePila'
    )
    apellidoPaterno = models.CharField(
        max_length=100,
        db_column='apellPaterno'
    )
    apellidoMaterno = models.CharField(
        max_length=100,
        blank=True,
        null=True,
        db_column='apellMaterno'
    )
    usuario = models.OneToOneField(
        Usuario,
        on_delete=models.CASCADE,
        related_name='alumno',
        db_column='usuario',
        to_field='codigo'
    )
    nivel = models.ForeignKey(
        'Nivel',
        on_delete=models.PROTECT,
        related_name='alumnos',
        db_column='nivel',
        to_field='codigo'
    )
    carrera = models.ForeignKey(
        'Carrera',
        on_delete=models.PROTECT,
        related_name='alumnos',
        db_column='carrera',
        to_field='clave'
    )

    class Meta:
        db_table = 'alumno'

    def __str__(self):
        return f"{self.matricula} - {self.nombre_pila} {self.apellidoPaterno}"
    
#MODELO ADMINISTRADOR
class Administrador(models.Model):
    clave = models.CharField(max_length=10, primary_key=True)
    nombre_pila = models.CharField(
        max_length=30,
        db_column='nombre_pila'
    )
    apellidoPaterno = models.CharField(
        max_length=30,
        db_column='apellPaterno'
    )
    apellidoMaterno = models.CharField(
        max_length=30,
        blank=True,
        null=True,
        db_column='apellMaterno'
    )
    usuario = models.OneToOneField(
        Usuario,
        on_delete=models.CASCADE,
        related_name='administrador',
        db_column='usuario',
        to_field='codigo'
    )

    class Meta:
        db_table = 'administrador'

    def __str__(self):
        return f"{self.nombre_pila} {self.apellidoPaterno}"
    
    
#MODELO CARRERA
class Carrera(models.Model):
    clave = models.CharField(max_length=10, primary_key=True)
    nombre = models.CharField(max_length=30)
    descripcion = models.CharField(max_length=255)
    
    class Meta:
        db_table = 'carrera'
        
    def __str__(self):
        return self.nombre
    

#MODELO GRUPO
class Grupo(models.Model):
    codigo = models.CharField(max_length=10, primary_key=True)
    
    nombre = models.CharField(max_length=50)
    fecha_creacion = models.DateField(
        db_column='fechaCreacion'
    )
    ciclo = models.CharField(max_length=100)
    
    profesor = models.ForeignKey(
        Profesor,
        on_delete=models.PROTECT,
        related_name='grupos',
        db_column='profesor',
        to_field='clave'
    )
    
    class Meta:
        db_table = 'grupo'
        
    def __str__(self):
        return self.nombre
    

#MODELO CATEGORIA
class Categoria(models.Model):
    codigo = models.CharField(max_length=10, primary_key=True)
    nombre = models.CharField(max_length=30)
    
    class Meta:
        db_table = 'categoria'
        
    def __str__(self):
        return self.nombre
    

#MODELO NIVEL
class Nivel(models.Model):
    codigo = models.CharField(max_length=2, primary_key=True)
    descripcion = models.CharField(max_length=100)
    
    class Meta:
        db_table = 'nivel'
        
    def __str__(self):
        return self.codigo
    

#MODELO PALABRA
class Palabra(models.Model):
    codigo = models.CharField(max_length=10, primary_key=True)
    significado = models.CharField(max_length=50)
    pronunciacion = models.CharField(max_length=100)
    imagen = models.ImageField(
        upload_to='palabras/imagenes/',
        max_length=100
    )
    audio = models.FileField(
        upload_to='palabras/audios/',
        max_length=100
    )
    categoria = models.ForeignKey(
        Categoria,
        on_delete=models.PROTECT,
        related_name='palabras',
        db_column='categoria',
        to_field='codigo'
    )
    nivel = models.ForeignKey(
        Nivel,
        on_delete=models.PROTECT,
        related_name='palabras',
        db_column='nivel',
        to_field='codigo'
    )

    class Meta:
        db_table = 'palabra'

    def __str__(self):
        return self.significado
    

#MODELO LISTA
class Lista(models.Model):
    codigo = models.CharField(max_length=10, primary_key=True)
    
    nombre = models.CharField(max_length=30)
    fecha_asignacion = models.DateField()
    fecha_limite = models.DateField(
        blank=True,
        null=True
    )
    numero_letras = models.IntegerField()
    
    profesor = models.ForeignKey(
        Profesor,
        on_delete=models.PROTECT,
        related_name='listas',
        db_column='profesor',
        to_field='clave'
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
        related_name='lista_palabras',
        db_column='lista',
        to_field='codigo'
    )
    
    palabra = models.ForeignKey(
        Palabra,
        on_delete=models.CASCADE,
        related_name='lista_palabras',
        db_column='palabra',
        to_field='codigo'
    )
    
    pk = models.CompositePrimaryKey(
        'lista',
        'palabra'
    )
    
    class Meta:
        db_table = 'lista_palabra'

#MODELO LISTA_GRUPO
class Lista_Grupo(models.Model):
    lista = models.ForeignKey(
        Lista,
        on_delete=models.CASCADE,
        related_name='lista_grupos',
        db_column='lista',
        to_field='codigo'
    )
    
    grupo = models.ForeignKey(
        Grupo,
        on_delete=models.CASCADE,
        related_name='lista_grupos',
        db_column='grupo',
        to_field='codigo'
    )
    
    pk = models.CompositePrimaryKey(
        'lista',
        'grupo'
    )
    
    class Meta:
        db_table = 'lista_grupo'

#MODELO GRUPO_ALUMNO
class Grupo_Alumno(models.Model):
    grupo = models.ForeignKey(
        Grupo,
        on_delete=models.CASCADE,
        related_name='grupo_alumnos',
        db_column='grupo',
        to_field='codigo'
    )
    
    alumno = models.ForeignKey(
        Alumno,
        on_delete=models.CASCADE,
        related_name='grupo_alumnos',
        db_column='alumno',
        to_field='matricula'
    )
    
    pk = models.CompositePrimaryKey(
        'grupo',
        'alumno'
    )
    
    class Meta:
        db_table = 'grupo_alumno'

#MODELO PROCESO_LISTA
class Proceso_Lista(models.Model):
    lista = models.ForeignKey(
        Lista,
        on_delete=models.CASCADE,
        related_name='procesos',
        db_column='lista',
        to_field='codigo'
    )
    
    alumno = models.ForeignKey(
        Alumno,
        on_delete=models.CASCADE,
        related_name='procesos_lista',
        db_column='alumno',
        to_field='matricula'
    )
    
    porcentaje_aciertos = models.FloatField(
        db_column='porcent_aciert'
    )
    
    lista_desbloqueada = models.CharField(
        max_length=10
    )
    
    fecha_completado = models.DateField()
    
    pk = models.CompositePrimaryKey(
        'lista',
        'alumno'
    )
    
    class Meta:
        db_table = 'proceso_lista'

#MODELO JUEGO
class Juego(models.Model):
    clave = models.CharField(max_length=10, primary_key=True)
    
    nombre = models.CharField(max_length=30)
    descripcion = models.CharField(max_length=255)
    mecanica = models.CharField(max_length=30)
    
    class Meta:
        db_table = 'juego'
        
    def __str__(self):
        return self.nombre

#MODELO DIFICULTAD
class Dificultad(models.Model):
    clave = models.CharField(max_length=10, primary_key=True)
    
    nombre = models.CharField(max_length=30)
    descripcion = models.CharField(max_length=100)
    
    class Meta:
        db_table = 'dificultad'
        
    def __str__(self):
        return self.nombre
    

#MODELO DIFICULTAD_JUEGO
class Dificultad_Juego(models.Model):
    juego = models.ForeignKey(
        Juego,
        on_delete=models.CASCADE,
        related_name='dificultades',
        db_column='juego',
        to_field='clave'
    )
    
    dificultad = models.ForeignKey(
        Dificultad,
        on_delete=models.CASCADE,
        related_name='juegos',
        db_column='dificultad',
        to_field='clave'
    )
    
    pk = models.CompositePrimaryKey(
        'juego',
        'dificultad'
    )
    
    class Meta:
        db_table = 'dificultad_juego'
    

#MODELO PRACTICA_SESION
class Practica_Sesion(models.Model):
    clave = models.CharField(max_length=10, primary_key=True)
    
    fecha = models.DateField()
    duracion = models.TimeField()
    porcentaje_aciertos = models.FloatField(
        db_column='porcent_aciertos'
    )
    
    puntos_obtenidos = models.FloatField(
        db_column='puntos_obt'
    )
    
    juego = models.ForeignKey(
        Juego,
        on_delete=models.PROTECT,
        related_name='practicas',
        db_column='juego',
        to_field='clave'
    )
    
    lista = models.ForeignKey(
        Lista,
        on_delete=models.PROTECT,
        related_name='practicas',
        db_column='lista',
        to_field='codigo'
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
        related_name='practicas',
        db_column='alumno',
        to_field='matricula'
    )
    
    practica_sesion = models.ForeignKey(
        Practica_Sesion,
        on_delete=models.CASCADE,
        related_name='alumnos',
        db_column='practica_sesion',
        to_field='clave'
    )
    
    pk = models.CompositePrimaryKey(
        'alumno',
        'practica_sesion'
    )
    
    class Meta:
        db_table = 'alumno_practica'

#MODELO INTENTO_PALABRA
class Intento_Palabra(models.Model):
    clave = models.CharField(max_length=10, primary_key=True)
    
    acertado = models.IntegerField()
    
    tiempo_respuesta = models.TimeField(
        blank=True,
        null=True
    )
    
    numero_intentos = models.IntegerField()
    
    practica_sesion = models.ForeignKey(
        Practica_Sesion,
        on_delete=models.CASCADE,
        related_name='intentos',
        db_column='practica_sesion',
        to_field='clave'
    )
    
    palabra = models.ForeignKey(
        Palabra,
        on_delete=models.PROTECT,
        related_name='intentos',
        db_column='palabra',
        to_field='codigo'
    )
    
    class Meta:
        db_table = 'intento_palabra'
        
    def __str__(self):
        return f"Intento {self.clave}"
    

#MODELO RANGO
class Rango(models.Model):
    codigo = models.CharField(max_length=10, primary_key=True)
    
    nombre = models.CharField(max_length=30)
    
    minimo = models.IntegerField()
    maximo = models.IntegerField(
        blank=True,
        null=True
    )
    
    alumno = models.ForeignKey(
        Alumno,
        on_delete=models.PROTECT,
        related_name='rangos',
        db_column='alumno',
        to_field='matricula'
    )
    
    class Meta:
        db_table = 'rango'
        
    def __str__(self):
        return self.nombre

#MODELO RANKING
class Ranking(models.Model):
    codigo = models.CharField(max_length=10, primary_key=True)
    
    nombre = models.CharField(max_length=30)
    posicion = models.PositiveIntegerField()
    periodo = models.CharField(max_length=20)
    
    puntos = models.IntegerField()
    
    alumno = models.ForeignKey(
        Alumno,
        on_delete=models.CASCADE,
        related_name='rankings',
        db_column='alumno',
        to_field='matricula'
    )
    
    class Meta:
        db_table = 'ranking'
        
    def __str__(self):
        return f"{self.nombre} - {self.posicion}"
    
#MODELO TIPO_RANKING
class TipoRanking(models.Model):
    codigo = models.CharField(max_length=10, primary_key=True)
    
    nombre = models.CharField(max_length=30)
    descripcion = models.CharField(max_length=50)
    ranking = models.ForeignKey(
        Ranking,
        on_delete=models.PROTECT,
        related_name='tipos_ranking',
        db_column='ranking',
        to_field='codigo'
    )
    
    class Meta:
        db_table = 'tipo_ranking'
        
    def __str__(self):
        return self.nombre
    

#MODELO INSIGNIA
class Insignia(models.Model):
    clave = models.CharField(max_length=10, primary_key=True)
    
    nombre = models.CharField(max_length=30)
    descripcion = models.CharField(max_length=100)
    criterio_obtencion = models.CharField(
        max_length=50,
        db_column='crit_obtencion'
    )
    
    class Meta:
        db_table = 'insignia'
        
    def __str__(self):
        return self.nombre

#MODELO ALUMNO_INSIGNIA
class Alumno_Insignia(models.Model):
    alumno = models.ForeignKey(
        Alumno,
        on_delete=models.CASCADE,
        related_name='insignias',
        db_column='alumno',
        to_field='matricula'
    )
    
    insignia = models.ForeignKey(
        Insignia,
        on_delete=models.CASCADE,
        related_name='alumnos',
        db_column='insignia',
        to_field='clave'
    )
    
    fecha_obtenida = models.DateField(
        blank=True,
        null=True,
        db_column='fecha_obtencion'
    )
    
    pk = models.CompositePrimaryKey(
        'alumno',
        'insignia'
    )
    
    class Meta:
        db_table = 'alumno_insignia'
        
#MODELO REPORTE
class Reporte(models.Model):
    codigo = models.CharField(max_length=10, primary_key=True)
    
    fecha_generacion = models.DateField(
        db_column='fecha_genera'
    )
    tipo_reporte = models.CharField(max_length=30)
    
    profesor = models.ForeignKey(
        Profesor,
        on_delete=models.PROTECT,
        related_name='reportes',
        db_column='profesor',
        to_field='clave'
    )
    
    class Meta:
        db_table = 'reporte'
        
    def __str__(self):
        return f"{self.tipo_reporte} - {self.codigo}"
    
#MODELO PUNTAJE
class Puntaje(models.Model):
    codigo = models.CharField(
        max_length=10,
        primary_key=True
    )
    
    experiencia = models.IntegerField()
    
    class Meta:
        db_table = 'puntaje'
        
    def __str__(self):
        return f"{self.codigo} - {self.experiencia}"
    
#MODELO LECCION
class Leccion(models.Model):
    clave = models.CharField(
        max_length=10,
        primary_key=True
    )
    
    nombre = models.CharField(max_length=30)
    descripcion = models.CharField(max_length=255)
    
    practica_sesion = models.ForeignKey(
        Practica_Sesion,
        on_delete=models.PROTECT,
        related_name='lecciones',
        db_column='practica_sesion',
        to_field='clave'
    )
    
    puntaje = models.ForeignKey(
        Puntaje,
        on_delete=models.PROTECT,
        related_name='lecciones',
        db_column='puntaje',
        to_field='codigo'
    )
    
    class Meta:
        db_table = 'leccion'
        
    def __str__(self):
        return self.nombre
    
#MODELO BITACORA_PROFESOR
class Bitacora_Profesor(models.Model):
    codigo = models.CharField(
        max_length=10,
        primary_key=True
    )
    
    fecha_generacion = models.DateField(
        db_column='fecha_generacion'
    )
    
    hora_generacion = models.TimeField(
        db_column='hora_generacion'
    )
    
    accion = models.CharField(max_length=255)
    
    profesor = models.ForeignKey(
        Profesor,
        on_delete=models.PROTECT,
        related_name='bitacoras',
        db_column='profesor',
        to_field='clave'
    )
    
    class Meta:
        db_table = 'bitacora_profesor'
        
    def __str__(self):
        return f"{self.codigo} - {self.accion}"
    
#MODELO BITACORA_ADMINISTRADOR
class Bitacora_Administrador(models.Model):
    codigo = models.CharField(
        max_length=10,
        primary_key=True
    )
    
    fecha_generacion = models.DateField(
        db_column='fecha_generacion'
    )
    
    hora_generacion = models.TimeField(
        db_column='hora_generacion'
    )
    
    accion = models.CharField(max_length=255)
    
    usuario = models.ForeignKey(
        Usuario,
        on_delete=models.PROTECT,
        related_name='bitacoras_administrador',
        db_column='usuario',
        to_field='codigo'
    )
    
    class Meta:
        db_table = 'bitacora_administrador'
        
    def __str__(self):
        return f"{self.codigo} - {self.accion}"
    
#MODELO GRUPO_CARRERA
class Grupo_Carrera(models.Model):
    grupo = models.ForeignKey(
        Grupo,
        on_delete=models.CASCADE,
        related_name='grupo_carreras',
        db_column='grupo',
        to_field='codigo'
    )
    
    carrera = models.ForeignKey(
        Carrera,
        on_delete=models.CASCADE,
        related_name='grupo_carreras',
        db_column='carrera',
        to_field='clave'
    )
    
    pk = models.CompositePrimaryKey(
        'grupo',
        'carrera'
    )
    
    class Meta:
        db_table = 'grupo_carrera'
        
#MODELO COPIA_SEGURIDAD
class Copia_Seguridad(models.Model):
    codigo = models.CharField(
        max_length=10,
        primary_key=True
    )
    
    nombre = models.CharField(max_length=50)
    fecha = models.DateField()
    hora = models.TimeField()
    datos = models.TextField()
    
    administrador = models.ForeignKey(
        Administrador,
        on_delete=models.PROTECT,
        related_name='copias_seguridad',
        db_column='administrador',
        to_field='clave'
    )
    
    class Meta:
        db_table = 'copia_seguridad'
        
    def __str__(self):
        return self.nombre
    
#MODELO COMPETENCIA
class Competencia(models.Model):
    codigo = models.CharField(
        max_length=10,
        primary_key=True
    )
    
    nombre = models.CharField(max_length=50)
    fecha = models.DateField()
    hora = models.TimeField()
    
    profesor = models.ForeignKey(
        Profesor,
        on_delete=models.PROTECT,
        related_name='competencias',
        db_column='profesor',
        to_field='clave'
    )
    
    class Meta:
        db_table = 'competencia'
        
    def __str__(self):
        return self.nombre
    
#MODELO LISTA_COMPETENCIA
class Lista_Competencia(models.Model):
    lista = models.ForeignKey(
        Lista,
        on_delete=models.CASCADE,
        related_name='lista_competencias',
        db_column='lista',
        to_field='codigo'
    )
    
    competencia = models.ForeignKey(
        Competencia,
        on_delete=models.CASCADE,
        related_name='lista_competencias',
        db_column='comeptencia',
        to_field='codigo'
    )
    
    pk = models.CompositePrimaryKey(
        'lista',
        'competencia'
    )
    
    class Meta:
        db_table = 'lista_competencia'
        
#MODELO ALUMNO_LECCION
class Alumno_Leccion(models.Model):
    alumno = models.ForeignKey(
        Alumno,
        on_delete=models.CASCADE,
        related_name='alumno_lecciones',
        db_column='alumno',
        to_field='matricula'
    )
    
    leccion = models.ForeignKey(
        Leccion,
        on_delete=models.CASCADE,
        related_name='alumno_lecciones',
        db_column='leccion',
        to_field='clave'
    )
    
    pk = models.CompositePrimaryKey(
        'alumno',
        'leccion'
    )
    
    class Meta:
        db_table = 'alumno_leccion'
        
#MODELO LISTA_LECCION
class Lista_Leccion(models.Model):
    lista = models.ForeignKey(
        Lista,
        on_delete=models.CASCADE,
        related_name='lista_lecciones',
        db_column='lista',
        to_field='codigo'
    )
    
    leccion = models.ForeignKey(
        Leccion,
        on_delete=models.CASCADE,
        related_name='lista_lecciones',
        db_column='leccion',
        to_field='clave'
    )
    
    pk = models.CompositePrimaryKey(
        'lista',
        'leccion'
    )
    
    class Meta:
        db_table = 'lista_leccion'