# BFF Gateway — Documentación Técnica
**RedNorte | Fullstack III | DuocUC**

---

## Índice

1. [Descripción general](#1-descripción-general)
2. [Arquetipo del microservicio](#2-arquetipo-del-microservicio)
3. [Arquitectura](#3-arquitectura)
4. [Patrones de diseño de software](#4-patrones-de-diseño-de-software)
5. [Stack tecnológico](#5-stack-tecnológico)
6. [Rutas y enrutamiento](#6-rutas-y-enrutamiento)
7. [DTOs](#7-dtos)
8. [Configuración](#8-configuración)

---

## 1. Descripción general

El **BFF Gateway** es el punto de entrada único de la plataforma RedNorte. Actúa como intermediario entre el frontend React y los microservicios internos, centralizando la seguridad, el enrutamiento y la resiliencia del sistema.

Su nombre proviene del patrón **Backend For Frontend** — un backend diseñado específicamente para las necesidades del frontend, que agrega y enruta peticiones hacia los microservicios correspondientes sin que el cliente sepa que existen múltiples servicios internos.

### Responsabilidades principales

- Recibir todas las peticiones del frontend en un único punto de entrada
- Validar tokens JWT antes de enrutar cualquier petición
- Enrutar peticiones hacia el microservicio correcto según el path
- Proteger el sistema con Circuit Breaker ante fallos de microservicios
- Permitir acceso público al portal del paciente sin autenticación

### Lo que NO hace este componente

- No contiene lógica de negocio
- No accede directamente a bases de datos
- No gestiona identidades de usuario
- No publica ni consume eventos RabbitMQ

---

## 2. Arquetipo del microservicio

### Estructura de carpetas

```
bff-gateway/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── cl/rednorte/bff_gateway/
│   │   │       ├── config/
│   │   │       │   ├── SecurityConfig.java      # Configuración de seguridad JWT
│   │   │       │   └── ResilientConfig.java     # Configuración Circuit Breaker
│   │   │       ├── filter/
│   │   │       │   └── JwtAuthFilter.java       # Filtro de autenticación JWT
│   │   │       ├── dto/
│   │   │       │   ├── request/                 # DTOs de entrada
│   │   │       │   │   ├── CrearSolicitudRequest.java
│   │   │       │   │   └── CambiarEstadoRequest.java
│   │   │       │   └── response/                # DTOs de salida
│   │   │       │       ├── SolicitudResponse.java
│   │   │       │       ├── SolicitudDetalleResponse.java
│   │   │       │       ├── HistorialEstadoResponse.java
│   │   │       │       ├── EspecialidadResponse.java
│   │   │       │       ├── PageResponse.java
│   │   │       │       ├── ConsultaPacienteDTO.java
│   │   │       │       └── SolicitudResumenDTO.java
│   │   │       ├── enums/
│   │   │       │   ├── NivelUrgencia.java
│   │   │       │   └── EstadoSolicitud.java
│   │   │       └── BffGatewayApplication.java
│   │   └── resources/
│   │       ├── application.yaml                 # Configuración principal
│   │       └── application-dev.yaml            # Configuración local (no va a GitHub)
│   └── test/
│       └── java/cl/rednorte/bff_gateway/
│           └── BffGatewayApplicationTests.java
├── .gitignore
├── pom.xml
└── README.md
```

### Convención de nombres

| Tipo | Convención | Ejemplo |
|------|-----------|---------|
| Configuraciones | Tecnología + Config | `SecurityConfig`, `ResilientConfig` |
| Filtros | Función + Filter | `JwtAuthFilter` |
| DTOs Request | Acción + Entidad + Request | `CrearSolicitudRequest` |
| DTOs Response | Entidad + Response | `SolicitudResponse` |
| Enums | PascalCase | `NivelUrgencia`, `EstadoSolicitud` |

---

## 3. Arquitectura

### Posición en la arquitectura global

```
React SPA (Frontend)
      │
      │ HTTP/HTTPS
      ▼
BFF Gateway (puerto 8090)
      │ valida JWT
      │ Circuit Breaker
      │
      ├──► /bff/lista-espera/**    → MS Lista de Espera   (8085)
      ├──► /bff/reasignacion/**    → MS Reasignación      (8086)
      ├──► /bff/notificaciones/**  → MS Notificaciones    (8087)
      └──► /bff/portal-pacientes/**→ MS Portal Pacientes  (8088)

Sistemas externos:
      ├── IdP RedNorte → valida JWT via JWKS
      └── RabbitMQ    → no aplica, el BFF no usa mensajería
```

### Flujo de una petición autenticada

```
1. Frontend envía petición con JWT en header Authorization
2. JwtAuthFilter intercepta la petición
3. SecurityConfig valida el JWT contra el IdP via JWKS
4. Si JWT válido → Gateway enruta al MS correspondiente
5. Circuit Breaker monitorea la respuesta del MS
6. Si MS responde → retorna respuesta al frontend
7. Si MS falla → Circuit Breaker activa fallback
```

### Flujo de una petición pública (portal paciente)

```
1. Paciente accede con RUT sin JWT
2. JwtAuthFilter omite la petición (shouldNotFilter)
3. SecurityConfig permite el acceso a /bff/portal-pacientes/**
4. Gateway enruta al MS Portal Pacientes (8088)
5. MS Portal Pacientes retorna datos de solo lectura
```

### Mapeo de rutas

| Path BFF | Microservicio | Puerto |
|----------|--------------|--------|
| /bff/lista-espera/** | MS Lista de Espera | 8085 |
| /bff/reasignacion/** | MS Reasignación | 8086 |
| /bff/notificaciones/** | MS Notificaciones | 8087 |
| /bff/portal-pacientes/** | MS Portal Pacientes | 8088 |

### ¿Qué hace StripPrefix=2?

Cuando el frontend llama a `/bff/lista-espera/solicitudes`, el Gateway elimina los primeros 2 segmentos del path (`/bff/lista-espera`) y enruta solo `/solicitudes` al MS Lista de Espera. Así el MS no necesita saber que existe el prefijo `/bff/lista-espera`.

```
Frontend:        GET /bff/lista-espera/solicitudes
Gateway enruta:  GET /solicitudes  →  http://localhost:8085
```

---

## 4. Patrones de diseño de software

### 4.1. Backend For Frontend (BFF)

**¿Qué es?**
Un backend diseñado específicamente para las necesidades del frontend. En lugar de que el frontend llame directamente a múltiples microservicios, llama a un único punto que se encarga de enrutar y agregar las respuestas.

**¿Dónde se aplica?**
En la arquitectura completa del sistema — el BFF Gateway es la implementación de este patrón.

**¿Cómo se implementa?**
```yaml
spring:
  cloud:
    gateway:
      server:
        webmvc:
          routes:
            - id: lista-espera
              uri: http://localhost:8085
              predicates:
                - Path=/bff/lista-espera/**
              filters:
                - StripPrefix=2
```

**¿Por qué se usa?**
- El frontend solo conoce una URL — el BFF. No necesita saber que existen 4 microservicios
- Si se agrega un nuevo microservicio, solo se agrega una ruta en el YAML del BFF
- La seguridad JWT se centraliza en un solo punto en lugar de implementarla en cada MS
- Reduce el acoplamiento entre el frontend y los microservicios internos

---

### 4.2. Circuit Breaker

**¿Qué es?**
Actúa como un cortacorriente inteligente. Si detecta que un microservicio está fallando repetidamente, "corta el circuito" hacia ese servicio y entrega una respuesta de fallback, evitando que un fallo en cascada afecte a todo el sistema.

**¿Dónde se aplica?**
En `ResilientConfig.java`:

```java
@Bean
public Customizer<Resilience4JCircuitBreakerFactory> defaultCustomizer() {
    return factory -> factory.configureDefault(id -> new Resilience4JConfigBuilder(id)
            .circuitBreakerConfig(CircuitBreakerConfig.custom()
                    .slidingWindowSize(10)
                    .failureRateThreshold(50)
                    .waitDurationInOpenState(Duration.ofSeconds(10))
                    .build())
            .build());
}
```

**¿Por qué se usa?**
- Si el MS Notificaciones falla, el MS Lista de Espera sigue funcionando con normalidad
- `slidingWindowSize(10)` → evalúa las últimas 10 peticiones
- `failureRateThreshold(50)` → si el 50% falla, abre el circuito
- `waitDurationInOpenState(10s)` → espera 10 segundos antes de reintentar

---

### 4.3. JWKS Stateless

**¿Qué es?**
El BFF valida la autenticidad del JWT usando la llave pública del IdP (JWKS) sin consultarlo en cada petición. La validación es criptográfica y local.

**¿Dónde se aplica?**
En `SecurityConfig.java` y `application.yaml`:

```java
@Bean
public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
    return http
            .csrf(AbstractHttpConfigurer::disable)
            .sessionManagement(session -> session
                    .sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                    .requestMatchers("/actuator/**").permitAll()
                    .requestMatchers("/bff/portal-pacientes/**").permitAll()
                    .anyRequest().authenticated()
            )
            .build();
}
```

**¿Por qué se usa?**
- Si el IdP falla temporalmente, los usuarios ya autenticados siguen operando con sus tokens vigentes
- No hay consulta al IdP en cada petición — la validación es local y rápida
- `SessionCreationPolicy.STATELESS` garantiza que no se guarda estado de sesión en el servidor

---

### 4.4. Token Propagation

**¿Qué es?**
El JWT recibido del frontend se propaga hacia los microservicios internos. Los microservicios extraen la información del usuario directamente del token sin consultar al IdP.

**¿Dónde se aplica?**
En `JwtAuthFilter.java`:

```java
@Override
protected void doFilterInternal(
        HttpServletRequest request,
        HttpServletResponse response,
        FilterChain filterChain) throws ServletException, IOException {

    String authHeader = request.getHeader(AUTH_HEADER);

    if (authHeader != null && authHeader.startsWith(BEARER_PREFIX)) {
        String token = authHeader.substring(BEARER_PREFIX.length());
        request.setAttribute("jwt_token", token);
    }

    filterChain.doFilter(request, response);
}
```

**¿Por qué se usa?**
- El RUT del funcionario viaja dentro del JWT — los microservicios lo extraen sin llamadas adicionales
- Elimina dependencias síncronas con el IdP en cada operación
- Reduce la latencia — no hay llamadas extra por petición

---

## 5. Stack tecnológico

| Tecnología | Versión | Propósito |
|-----------|---------|-----------|
| Java | 21 LTS | Lenguaje de programación |
| Spring Boot | 3.5.14 | Framework principal |
| Spring Cloud Gateway | 2025.0.2 | Enrutamiento de peticiones |
| Spring Security | 6.5.10 | Autenticación y autorización JWT |
| Spring Boot Actuator | 3.5.14 | Monitoreo y health checks |
| Resilience4j | latest | Circuit Breaker |
| WebFlux | 3.5.14 | Programación reactiva |
| Lombok | latest | Reducción de código boilerplate |
| Maven | 3.9.15 | Gestión de dependencias y build |

---

## 6. Rutas y enrutamiento

### Rutas públicas (sin JWT)

| Método | Path | Descripción |
|--------|------|-------------|
| GET | /actuator/health | Estado del BFF |
| GET | /bff/portal-pacientes/** | Portal de consulta para pacientes |

### Rutas protegidas (requieren JWT)

| Método | Path BFF | Enruta a |
|--------|----------|----------|
| GET | /bff/lista-espera/especialidades | MS Lista de Espera — GET /especialidades |
| POST | /bff/lista-espera/solicitudes | MS Lista de Espera — POST /solicitudes |
| GET | /bff/lista-espera/solicitudes | MS Lista de Espera — GET /solicitudes |
| GET | /bff/lista-espera/solicitudes/{id} | MS Lista de Espera — GET /solicitudes/{id} |
| PATCH | /bff/lista-espera/solicitudes/{id}/estado | MS Lista de Espera — PATCH /solicitudes/{id}/estado |
| GET | /bff/reasignacion/medicos | MS Reasignación — GET /medicos |
| GET | /bff/reasignacion/horas-medicas | MS Reasignación — GET /horas-medicas |
| POST | /bff/reasignacion/horas-medicas | MS Reasignación — POST /horas-medicas |
| GET | /bff/reasignacion/tasks | MS Reasignación — GET /tasks |
| PATCH | /bff/reasignacion/tasks/{id}/completar | MS Reasignación — PATCH /tasks/{id}/completar |
| GET | /bff/notificaciones | MS Notificaciones — GET /notificaciones |

---

## 7. DTOs

### Request

| DTO | Propósito |
|-----|-----------|
| `CrearSolicitudRequest` | Datos para registrar una nueva solicitud |
| `CambiarEstadoRequest` | Nuevo estado y motivo para cambiar estado |

### Response

| DTO | Propósito |
|-----|-----------|
| `SolicitudResponse` | Vista resumida de una solicitud para listas |
| `SolicitudDetalleResponse` | Vista completa con historial de estados |
| `HistorialEstadoResponse` | Registro de un cambio de estado |
| `EspecialidadResponse` | Datos de una especialidad médica |
| `PageResponse<T>` | Wrapper genérico para listas paginadas |
| `ConsultaPacienteDTO` | Registro de consulta del paciente para auditoría |
| `SolicitudResumenDTO` | Resumen de solicitud para el portal del paciente |

### Enums

| Enum | Valores |
|------|---------|
| `NivelUrgencia` | GES, URGENTE, ELECTIVA |
| `EstadoSolicitud` | EN_ESPERA, CITADO, ATENDIDO, AUSENTE, CERRADO, ANULADO, DERIVADO, VENCIDO |

---

## 8. Configuración

### application.yaml

```yaml
server:
  port: 8090

spring:
  application:
    name: bff-gateway

  cloud:
    gateway:
      server:
        webmvc:
          routes:
            - id: lista-espera
              uri: http://localhost:8085
              predicates:
                - Path=/bff/lista-espera/**
              filters:
                - StripPrefix=2

            - id: reasignacion
              uri: http://localhost:8086
              predicates:
                - Path=/bff/reasignacion/**
              filters:
                - StripPrefix=2

            - id: notificaciones
              uri: http://localhost:8087
              predicates:
                - Path=/bff/notificaciones/**
              filters:
                - StripPrefix=2

            - id: portal-pacientes
              uri: http://localhost:8088
              predicates:
                - Path=/bff/portal-pacientes/**
              filters:
                - StripPrefix=2

  security:
    oauth2:
      resourceserver:
        jwt:
          jwk-set-uri: ${IDP_JWKS_URI:http://localhost:9000/.well-known/jwks.json}

management:
  endpoints:
    web:
      exposure:
        include: health, info
```

### Variables de entorno

| Variable | Descripción | Default |
|----------|-------------|---------|
| IDP_JWKS_URI | URL del proveedor de identidad para validar JWT | http://localhost:9000/.well-known/jwks.json |

### Puertos del sistema

| Componente | Puerto |
|-----------|--------|
| BFF Gateway | 8090 |
| MS Lista de Espera | 8085 |
| MS Reasignación | 8086 |
| MS Notificaciones | 8087 |
| MS Portal Pacientes | 8088 |
| MySQL | 3306 |
| RabbitMQ | 5672 |
| RabbitMQ Panel | 15672 |

### Cómo ejecutar localmente

```bash
# 1. Clonar el repositorio
git clone https://github.com/Fullstack3RedNorte/BFF-Gateway.git

# 2. Iniciar XAMPP (MySQL) y Docker (RabbitMQ)
docker run -d --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3.13-management

# 3. Levantar los microservicios en orden
# MS Lista de Espera  → puerto 8085
# MS Reasignación     → puerto 8086
# MS Notificaciones   → puerto 8087
# MS Portal Pacientes → puerto 8088

# 4. Ejecutar el BFF
cd BFF-Gateway
mvn spring-boot:run

# 5. Verificar que el BFF está corriendo
curl http://localhost:8090/actuator/health
```

### Verificar enrutamiento

```bash
# Listar especialidades via BFF
GET http://localhost:8090/bff/lista-espera/especialidades

# Crear solicitud via BFF
POST http://localhost:8090/bff/lista-espera/solicitudes

# Consultar portal paciente via BFF (sin JWT)
GET http://localhost:8090/bff/portal-pacientes/solicitudes?rutPaciente=12345678-9
```

---

*Documentación generada para el proyecto semestral Fullstack III — RedNorte — DuocUC 2026*
