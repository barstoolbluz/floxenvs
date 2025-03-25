# 🔄 A Flox Environment for Working with Python and PostgreSQL

This environment gives you a Python 3.12 setup preconfigured for database work with SQLAlchemy, Alembic, and all the build dependencies you need to connect to PostgreSQL without the usual headaches.

## ✨ Features

- Ready-to-use SQLAlchemy and Alembic setup
- All PostgreSQL driver dependencies pre-installed
- Smart venv management that doesn't get in your way
- Cross-platform support with zero configuration
- Compiler toolchain included for native extensions

## 🧰 What's Inside

- `python312` - Latest current-stable Python 3.12 package; use **`flox edit`** to change versions
- `SQLAlchemy` - The Python SQL toolkit and ORM
- `Alembic` - Database migration tool that doesn't suck
- `gcc` + `zlib` - Build dependencies for psycopg2
- `pip` - Latest Python package manager
- `gum` - Clean terminal UI for environments
- `bat` - Used for `readme` function

## 🚀 Getting Started

### Prerequisites

- [Flox](https://flox.dev/get) installed
- That's it

### Setup

```sh
git clone https://github.com/youruser/sqlalchemy-env && cd sqlalchemy-env
flox activate
```

## 📝 Built-in Commands

### Environment Management

```bash
# Create a new virtual environment
mkvenv

# Activate any venv in the current directory tree
aktivate

# Exit the current virtual environment
qwit
```

### Package Management

```bash
# Install dependencies from requirements.txt
pist

# Install from a different requirements file
pist dev-requirements.txt
```

## 🔧 What This Solves

- **No more psycopg2 build errors** - All required libraries are included
- **No more "I can't find my venv"** - The `aktivate` command scans the directory tree
- **No more dependency conflicts** - Isolated Python environment
- **No more migrations headaches** - Alembic is ready to use

## 🔥 Troubleshooting

1. **psycopg2 installation issues**:
   - If you still have issues, try `pip install psycopg2-binary` instead
   - Make sure you've activated a venv first with `aktivate`

2. **Virtual environment problems**:
   - Try `rm -rf .venv` and create a fresh one with `mkvenv`
   - Check that Python 3.12 is correctly installed in your Flox environment

3. **SQLAlchemy connection issues**:
   - Verify PostgreSQL is running and accessible
   - Check connection strings for typos
   - Make sure any required database roles exist

## 💻 System Support

Works on:
- macOS (ARM/Intel)
- Linux (ARM/x86)

## 🔍 Pro Tips

- Use SQLAlchemy's connection pooling for better performance
- Set up Alembic migrations early in your project
- Consider using SQLAlchemy 2.0-style queries for future compatibility
- If working with large databases, enable SQLAlchemy's query profiling

## About Flox

[Flox](https://flox.dev/docs) combines package and environment management, building on [Nix](https://github.com/NixOS/nix). It gives you Nix with a `git`-like syntax and an intuitive UX:

- **Declarative environments**. Software packages, variables, services, etc. are defined in simple, human-readable TOML format;
- **Content-addressed storage**. Multiple versions of packages with conflicting dependencies can coexist in the same environment;
- **Reproducibility**. The same environment can be reused across development, CI, and production;
- **Deterministic builds**. The same inputs always produce identical outputs for a given architecture, regardless of when or where builds occur;
- **World's largest collection of packages**. Access to over 150,000 packages—and millions of package-version combinations—from [Nixpkgs](https://github.com/NixOS/nixpkgs).
