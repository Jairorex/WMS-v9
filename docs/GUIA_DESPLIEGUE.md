# 🚀 Opciones de Despliegue WMS Escasan - Guía Completa

## 🎯 Introducción

Esta guía presenta las **mejores opciones** para desplegar el Sistema WMS Escasan en otra PC, con ventajas, desventajas y recomendaciones para cada método.

## 📊 Comparación de Opciones

| Opción | Facilidad | Velocidad | Requisitos | Recomendación |
|--------|----------|-----------|------------|----------------|
| **1. ZIP con Scripts** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | Manual | ⭐⭐⭐⭐⭐ |
| **2. Instalador Ejecutable** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | Automático | ⭐⭐⭐⭐⭐ |
| **3. Docker** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | Docker | ⭐⭐⭐⭐ |
| **4. Servidor Web** | ⭐⭐ | ⭐⭐⭐ | IIS/Nginx | ⭐⭐⭐ |
| **5. Paquete Portable** | ⭐⭐⭐⭐ | ⭐⭐⭐ | Sin instalación | ⭐⭐⭐⭐ |

---

## 🥇 Opción 1: Paquete ZIP con Scripts Automatizados (RECOMENDADA)

### ✅ **Ventajas**
- ✅ No requiere permisos de administrador para la mayoría de operaciones
- ✅ Fácil de distribuir (un solo archivo ZIP)
- ✅ Instalación rápida (10-15 minutos)
- ✅ Control total sobre el proceso
- ✅ Incluye todos los scripts necesarios
- ✅ Documentación completa incluida

### ⚠️ **Desventajas**
- ⚠️ Requiere que el usuario instale dependencias manualmente (PHP, Node.js, SQL Server)
- ⚠️ Requiere conocimientos básicos de Windows

### 📦 **Estructura del Paquete**
```
WMS-Escasan-v1.0.zip
├── backend/              # Código fuente completo
├── frontend/             # Código fuente completo
├── database/             # Scripts SQL
├── scripts/              # Scripts de instalación
├── docs/                 # Documentación
├── INSTALAR.bat          # Instalador principal
├── INSTALAR_SIN_ADMIN.bat # Instalador sin admin
└── README.txt            # Instrucciones rápidas
```

### 🔧 **Proceso de Instalación**
1. Extraer ZIP en `C:\WMS-Escasan`
2. Ejecutar `INSTALAR_SIN_ADMIN.bat`
3. Configurar base de datos
4. Iniciar servicios

**Tiempo estimado**: 15-20 minutos  
**Nivel de dificultad**: Bajo-Medio

---

## 🥈 Opción 2: Instalador Ejecutable (Más Profesional)

### ✅ **Ventajas**
- ✅ Experiencia profesional de instalación
- ✅ Interfaz gráfica de usuario (GUI)
- ✅ Verificación automática de requisitos
- ✅ Instalación completamente automatizada
- ✅ Desinstalador incluido
- ✅ Actualizaciones automáticas (opcional)

### ⚠️ **Desventajas**
- ⚠️ Requiere herramientas adicionales (InnoSetup, NSIS)
- ⚠️ Desarrollo más complejo
- ⚠️ Tamaño del instalador mayor

### 🛠️ **Herramientas Recomendadas**

#### **InnoSetup** (Recomendado)
- ✅ Gratuito y open source
- ✅ Fácil de usar
- ✅ Excelente para aplicaciones Windows
- ✅ Soporte para scripts personalizados

#### **NSIS (Nullsoft Scriptable Install System)**
- ✅ Muy potente y flexible
- ✅ Scripts avanzados
- ✅ Curva de aprendizaje media

### 📝 **Ejemplo de Script InnoSetup**
```pascal
[Setup]
AppName=WMS Escasan
AppVersion=1.0
DefaultDirName={pf}\WMS-Escasan
DefaultGroupName=WMS Escasan
OutputBaseFilename=WMS-Escasan-Setup
Compression=lzma
SolidCompression=yes

[Files]
Source: "backend\*"; DestDir: "{app}\backend"; Flags: recursesubdirs
Source: "frontend\*"; DestDir: "{app}\frontend"; Flags: recursesubdirs
Source: "database\*"; DestDir: "{app}\database"; Flags: recursesubdirs

[Icons]
Name: "{group}\WMS Escasan"; Filename: "http://localhost:5174"
Name: "{commondesktop}\WMS Escasan"; Filename: "http://localhost:5174"
```

**Tiempo estimado**: 5-10 minutos  
**Nivel de dificultad**: Muy Bajo

---

## 🥉 Opción 3: Docker (Para Entornos Técnicos)

### ✅ **Ventajas**
- ✅ Aislamiento completo del sistema
- ✅ Reproducible en cualquier máquina
- ✅ No requiere instalación de dependencias en el host
- ✅ Fácil de actualizar
- ✅ Perfecto para desarrollo y producción

### ⚠️ **Desventajas**
- ⚠️ Requiere Docker instalado
- ⚠️ Curva de aprendizaje para usuarios no técnicos
- ⚠️ Configuración más compleja para SQL Server

### 🐳 **Estructura Docker**
```
docker/
├── docker-compose.yml    # Orquestación completa
├── Dockerfile.backend    # Contenedor Laravel
├── Dockerfile.frontend   # Contenedor React
└── docker-compose.prod.yml # Producción
```

### 📝 **docker-compose.yml**
```yaml
version: '3.8'

services:
  sqlserver:
    image: mcr.microsoft.com/mssql/server:2022-latest
    environment:
      - ACCEPT_EULA=Y
      - SA_PASSWORD=YourStrong@Password123
    ports:
      - "1433:1433"
    volumes:
      - sqlserver_data:/var/opt/mssql

  backend:
    build:
      context: ../backend
      dockerfile: Dockerfile
    ports:
      - "8000:8000"
    depends_on:
      - sqlserver
    environment:
      - DB_HOST=sqlserver
      - DB_PASSWORD=YourStrong@Password123

  frontend:
    build:
      context: ../frontend
      dockerfile: Dockerfile
    ports:
      - "5174:5174"
    depends_on:
      - backend

volumes:
  sqlserver_data:
```

**Tiempo estimado**: 20-30 minutos (primera vez)  
**Nivel de dificultad**: Medio-Alto

---

## 📦 Opción 4: Servidor Web (IIS/Nginx)

### ✅ **Ventajas**
- ✅ Producción lista
- ✅ Mejor rendimiento
- ✅ SSL/HTTPS fácil
- ✅ Múltiples usuarios simultáneos
- ✅ Servicios como Windows Services

### ⚠️ **Desventajas**
- ⚠️ Configuración compleja
- ⚠️ Requiere conocimientos de servidores web
- ⚠️ Más tiempo de configuración

### 🌐 **Configuración Recomendada**
- **IIS** con PHP Manager para Windows
- **Nginx** con PHP-FPM (más complejo en Windows)
- **Apache** con mod_php

**Tiempo estimado**: 1-2 horas  
**Nivel de dificultad**: Alto

---

## 💼 Opción 5: Paquete Portable (Sin Instalación)

### ✅ **Ventajas**
- ✅ No requiere instalación
- ✅ Ejecución desde USB
- ✅ Sin permisos de administrador
- ✅ Fácil de mover entre PCs
- ✅ No modifica el registro de Windows

### ⚠️ **Desventajas**
- ⚠️ Requiere PHP y Node.js portables
- ⚠️ SQL Server debe estar instalado
- ⚠️ Configuración manual de base de datos

### 📁 **Estructura Portable**
```
WMS-Escasan-Portable/
├── backend/
├── frontend/
├── php/              # PHP portable
├── nodejs/           # Node.js portable
├── database/
└── INICIAR.bat       # Script de inicio
```

**Tiempo estimado**: 10 minutos (ya configurado)  
**Nivel de dificultad**: Bajo

---

## 🎯 **Recomendación Final**

### Para la mayoría de casos: **Opción 1 (ZIP con Scripts)**

**Razones:**
1. ✅ Balance perfecto entre facilidad y control
2. ✅ No requiere herramientas adicionales
3. ✅ Fácil de mantener y actualizar
4. ✅ Documentación completa incluida
5. ✅ Funciona en cualquier Windows 10/11

### Para usuarios finales: **Opción 2 (Instalador Ejecutable)**

**Razones:**
1. ✅ Experiencia profesional
2. ✅ Instalación completamente automatizada
3. ✅ Desinstalación fácil
4. ✅ Interfaz gráfica amigable

### Para entornos técnicos: **Opción 3 (Docker)**

**Razones:**
1. ✅ Reproducible y escalable
2. ✅ Aislamiento completo
3. ✅ Fácil de actualizar
4. ✅ Perfecto para desarrollo y producción

---

## 📋 Checklist de Despliegue

### ✅ **Preparación**
- [ ] Verificar que todas las dependencias estén incluidas
- [ ] Probar instalación en PC limpia
- [ ] Documentar todos los pasos
- [ ] Crear scripts de verificación
- [ ] Preparar guía de solución de problemas

### ✅ **Empaquetado**
- [ ] Incluir todo el código fuente
- [ ] Incluir scripts SQL
- [ ] Incluir documentación
- [ ] Crear scripts de instalación
- [ ] Probar extracción del ZIP

### ✅ **Distribución**
- [ ] Compartir archivo ZIP
- [ ] Proporcionar instrucciones claras
- [ ] Ofrecer soporte técnico
- [ ] Documentar requisitos del sistema

---

## 🚀 **Próximos Pasos**

1. **Elegir la opción** que mejor se adapte a tus necesidades
2. **Crear el paquete** usando los scripts proporcionados
3. **Probar la instalación** en una PC limpia
4. **Distribuir el paquete** a los usuarios finales

---

**¿Necesitas ayuda?** Consulta la documentación completa en la carpeta `docs/`
