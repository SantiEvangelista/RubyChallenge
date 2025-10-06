<img width="1906" height="884" alt="image" src="https://github.com/user-attachments/assets/ad4733d7-1ea4-4a1c-8dd1-9bc7a446e403" />


# FUDO Ruby Challenge - API REST

API REST desarrollada con Ruby que implementa un sistema de gestión de productos con creación asíncrona, autenticación JWT, pruebas con RSpec y documentación OpenAPI + Swagger.

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
- **Swagger UI**: Interfaz visual para explorar la documentación
- **Caché Inteligente**: Headers de caché configurados según especificaciones

---

## 🚀 Instalación

### Docker - Un solo comando

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

# La API estará disponible en:
# - Swagger UI: http://localhost:8080
# - API Endpoints: http://localhost:8080/products
# - OpenAPI Spec: http://localhost:8080/openapi.yaml
```

Para detener:
```bash
docker-compose down
```

---

## 🏗️ Arquitectura

El proyecto sigue una arquitectura modular y escalable basada en el **Action Pattern**, con clara separación de responsabilidades:

```
RubyChallenge/
├── app/
│   ├── actions/          # Action Pattern - Lógica de negocio encapsulada
│   │   ├── authenticate_user.rb
│   │   ├── create_product.rb
│   │   ├── list_products.rb
│   │   ├── show_product.rb
│   │   └── get_job_status.rb
│   ├── jobs/             # Background Jobs - Procesamiento asíncrono
│   │   └── product_job.rb
│   └── models/           # ActiveRecord Models - Capa de persistencia
│       └── product.rb
├── config/
│   └── environment.rb    # Configuración de base de datos y entorno
├── db/
│   ├── migrate/          # Migraciones de base de datos
│   └── seeds.rb          # Datos de prueba
├── spec/                 # Tests RSpec
│   ├── actions/          # Tests unitarios de actions
│   ├── integration/      # Tests de integración (Rswag)
│   ├── spec_helper.rb
│   └── swagger_helper.rb
├── views/                # Vistas ERB
│   └── swagger_ui.erb    # Interfaz Swagger UI
├── bruno/                # Colección de requests para testing manual
│   ├── requests/
│   └── environments/
├── public/               # Archivos estáticos
│   ├── openapi.yaml
│   └── AUTHORS
├── tcp.md                # Explicación de TCP
├── http.md               # Explicación de HTTP
└── fudo.md               # Descripción de Fudo
```


## 👤 Contacto

**Santiago Evangelista**  
Ingeniero Informático

---

## 🙏 Agradecimientos

Gracias por revisar este proyecto. Espero que cumpla las expectativas solicitadas.
