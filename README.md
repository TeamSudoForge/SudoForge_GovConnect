# GovConnect

### Folder Structure

```
govconnect/
│
├── frontend/                          			# Flutter mobile application source code
│   ├── lib/
│   │   ├── main.dart                  			# App entry point
│   │   └── src/
│   │       ├── presentation/          			# UI Layer: screens, widgets, Provider state, localization, error handling
│   │       │   ├── screens/            		# All app pages and views
│   │       │   ├── widgets/            		# Reusable UI components
│   │       │   ├── state/              		# Provider ChangeNotifier classes for global state management
│   │       │   ├── localization/       		# Multilingual support files and logic
│   │       │   └── error_handling/     		# Global error handling and backend error mapping
│   │       │
│   │       ├── domain/                 		# Domain Layer: business logic and core app models
│   │       │   ├── entities/           		# Core business entities
│   │       │   ├── usecases/           		# Business rules and application logic
│   │       │   └── repositories/       		# Abstract interfaces for data access
│   │       │
│   │       ├── data/                   		# Data Layer: implementations for data sources and repositories
│   │       │   ├── repositories_impl/  		# Concrete repository implementations
│   │       │   ├── datasources/        		# Data sources for local and remote data
│   │       │   │   ├── local/          		# Local storage implementations
│   │       │   │   │   ├── hive/       		# Hive database adapters and box setups
│   │       │   │   │   ├── secure_storage/ 		# flutter_secure_storage helpers for sensitive data
│   │       │   │   │   └── file_storage/   		# path_provider utilities for file paths
│   │       │   │   └── remote/         		# API client implementations (HTTP/GraphQL)
│   │       │   └── models/             		# Data Transfer Objects (DTOs) for serialization
│   │       │
│   │       ├── core/                   		# Core shared utilities and configs
│   │       │   ├── constants/          		# App-wide constants
│   │       │   ├── theme/              		# Light/dark mode themes and font size configs
│   │       │   ├── utils/              		# Helper functions and utilities
│   │       │   ├── error/              		# Common error classes and handling utilities
│   │       │   └── storage_keys.dart   		# Centralized keys for local storage
│   │       │
│   │       └── injection.dart          		# Dependency injection setup (e.g., Provider bindings)
│   │
│   ├── assets/                        		# Static resources: images, fonts, translations
│   ├── test/                          			# Unit and widget tests for the Flutter app
│   └── pubspec.yaml                   		# Flutter project dependencies and metadata
│
├── backend/                          		# NestJS backend API source code
│   ├── src/
│   │   ├── modules/                   		# Feature modules grouping controllers and services
│   │   ├── controllers/               		# HTTP request handlers for APIs
│   │   ├── services/                 		 # Business logic implementations
│   │   ├── entities/                  		# TypeORM database entities
│   │   ├── migrations/                		# TypeORM migration scripts
│   │   ├── filters/                   		# Global error filters and exception handling
│   │   ├── interceptors/              		# Response interceptors (optional)
│   │   ├── middlewares/               		# Middleware (logging, auth, etc.)
│   │   ├── guards/                    		# Route guards for auth and access control
│   │   ├── pipes/                    		# Validation and transformation pipes
│   │   ├── config/                   		# Configuration files (DB, env, etc.)
│   │   ├── utils/                    			# Utility functions and helpers
│   │   └── main.ts                  			# Entry point of NestJS app
│   ├── tests/                        			# Unit and integration tests for backend
│   ├── ormconfig.ts                  		# TypeORM configuration file
│   ├── migration-config.ts           		# TypeORM migration CLI config
│   └── package.json                  		# NPM dependencies and scripts
│
├── docs/                            			# Project documentation
│   ├── architecture.md              			# System design and architecture docs
│   ├── api-spec.md                 			# API endpoint specifications
│   ├── deployment.md                			# Deployment and environment setup guides
│   └── ...                         			# Other project-related docs
│
├── docker/                          			# Docker containerization configs
│   ├── backend.Dockerfile           			# Dockerfile for backend service
│   ├── frontend.Dockerfile          			# Dockerfile for Flutter frontend
│   ├── docker-compose.yml           			# Compose file for multi-service orchestration
│   ├── mailhog.Dockerfile           			# Dev mail server container setup
│   ├── minio.Dockerfile             			# File storage service container
│   └── db.Dockerfile                			# Database container setup
│
├── .gitignore                      			# Git ignore rules
├── README.md                       			# Project overview and instructions
└── LICENSE                        			# License file

```
