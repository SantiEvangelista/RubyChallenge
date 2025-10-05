# Ruby Challenge - API REST Asíncrona

API REST desarrollada con Ruby/Sinatra que implementa un sistema de gestión de productos con creación asíncrona, autenticación JWT , pruebas con Spec y documentación OpenAPI.

**Autor:** Santiago Evangelista - Ingeniero Informático

---

## 📋 Tabla de Contenidos

- [Descripción](#-descripción)
- [Instalación](#-instalación)
- [Arquitectura](#-arquitectura)
- [Tecnologías Utilizadas](#-tecnologías-utilizadas)

---

## 📖 Descripción

Esta API implementa un sistema completo de gestión de productos con las siguientes características destacadas:

- **Autenticación JWT**: Sistema seguro de autenticación basado en tokens
- **Procesamiento Asíncrono**: Creación de productos con delay configurable (por defecto 5 segundos)
- **Tracking de Jobs**: Sistema de seguimiento del estado de operaciones asíncronas
- **Documentación OpenAPI**: Especificación completa de la API en formato OpenAPI 3.0
- **Caché Inteligente**: Headers de caché configurados según especificaciones

---

## 🚀 Instalación

### Opción 1: Docker  - Un solo comando

Esta es la forma más rápida de empezar. Con un solo comando se realizan automáticamente:
- Build del contenedor
- Instalación de dependencias
- Ejecución de migraciones
- Carga de datos de prueba (seeds)
- Inicio del servidor

```bash
# Clonar el repositorio
git clone <repository-url>
cd RubyChallenge

# Levantar todo con un solo comando
docker-compose up --build

# La API estará disponible en http://localhost:8080
```

Para detener:
```bash
docker-compose down
```

## 🏗️ Arquitectura

El proyecto sigue una arquitectura modular y escalable basada en el **Action Pattern** (también conocido como **Command Pattern**), con clara separación de responsabilidades:

```
RubyChallenge/
├── app/
│   ├── actions/          # Actions (Command Pattern) - Lógica de negocio
│   │   ├── authenticate_user.rb
│   │   ├── create_product.rb
│   │   ├── list_products.rb
│   │   ├── show_product.rb
│   │   └── get_job_status.rb
│   ├── jobs/             # Background Jobs - Procesamiento asíncrono
│   │   └── product_job.rb
│   └── models/           # ActiveRecord Models
│       └── product.rb
├── config/
│   └── environment.rb    # Configuración de base de datos y entorno
├── db/
│   ├── migrate/          # Migraciones de base de datos
│   └── seeds.rb          # Datos de prueba
├── spec/                 # Tests RSpec
│   ├── actions/
│   └── spec_helper.rb
├── bruno/                # Colección de requests para testing manual
│   ├── requests/
│   └── environments/
└── public/               # Archivos estáticos
    ├── openapi.yaml
    └── AUTHORS
```

### Principios de Arquitectura

#### 1. **Actions (Command Pattern)**
Cada funcionalidad de negocio está encapsulada en una clase Action con un método `call` estático. Esto proporciona:
- **Single Responsibility**: Cada action tiene una única responsabilidad
- **Testabilidad**: Fácil de testear de forma aislada
- **Reutilización**: Pueden ser llamadas desde cualquier parte de la aplicación
- **Mantenibilidad**: Código organizado y fácil de entender

Ejemplo:
```ruby
module Actions
  class CreateProduct
    def self.call(product_params, delay_seconds = 5)
      # Lógica de validación y creación asíncrona
    end
  end
end
```

#### 2. **Jobs (Background Processing)**
Sistema de procesamiento asíncrono usando threads nativos de Ruby:
- Almacenamiento de jobs en memoria con hash
- Estados del job: `pending`, `processing`, `completed`, `failed`
- Delay configurable con validación (min: 1s, max: 120s)
- Tracking completo del ciclo de vida del job

#### 3. **Models (ActiveRecord)**
Capa de persistencia usando ActiveRecord ORM:
- Validaciones a nivel de modelo
- Migraciones versionadas
- Seeds para datos de prueba

#### 4. **Testing**
Suite completa de tests con RSpec:
- Tests unitarios de actions
- Tests de integración de endpoints
- Cobertura de casos edge
- Tests de autenticación y autorización

#### 5. **Testing Manual con Bruno**
Colección completa de requests HTTP para testing manual:
- Entornos configurables (local, production)
- Variables de entorno para tokens
- Requests pre-configuradas para todos los endpoints
- Ideal para demostración y debugging

---

## 🛠️ Tecnologías Utilizadas

### Framework y Lenguaje
- **Ruby 3.2**: Lenguaje de programación
- **Sinatra**: Micro-framework web minimalista y flexible
- **Rack**: Interface entre servidores web y frameworks Ruby

### Base de Datos y ORM
- **SQLite3**: Base de datos embebida (fácil para desarrollo y demo)
- **ActiveRecord**: ORM para interacción con la base de datos
- **ActiveSupport**: Utilidades y extensiones de Ruby on Rails

### Autenticación y Seguridad
- **JWT (JSON Web Tokens)**: Sistema de autenticación stateless
- **BCrypt** (implícito): Para hashing seguro de contraseñas

### Testing y Quality Assurance
- **RSpec**: Framework principal de testing
- **Rack::Test**: Librería para testing de aplicaciones Rack/Sinatra
- **Bruno**: Cliente HTTP moderno para testing manual e integración de APIs

### DevOps y Deployment
- **Docker**: Containerización de la aplicación
- **Docker Compose**: Orquestación de contenedores
- **Puma**: Servidor web de alto rendimiento
- **Rake**: Task runner para migraciones y seeds

### Documentación
- **OpenAPI 3.0**: Especificación estándar de la API

---


## 👤 Contacto

**Santiago Evangelista**  
Ingeniero Informático

---

## 🙏 Agradecimientos

Gracias por revisar este proyecto. Espero que la documentación sea clara y el código demuestre las mejores prácticas de desarrollo en Ruby.
