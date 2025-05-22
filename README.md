# Clean Code Workshop

This is an example repository used for a workshop that demonstrates core "Clean Code" principles using Ruby on Rails.

[![CI](https://github.com/Bodacious/CleanCodeWorkshop/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/Bodacious/CleanCodeWorkshop/actions/workflows/ci.yml)

## 📥 Downloading

To clone the repository:

```bash
git clone https://github.com/bodacious/cleancodeworkshop.git
cd cleancodeworkshop
```

## ⚙️ Setup

Install dependencies and prepare the environment:

```bash
bin/setup
```

## 🧪 Running the Test Suite

To execute the full test suite:

```bash
bundle exec rails test
```

## 🚀 Running the Main Application Server

To start the Rails server with development tools:

```bash
bin/dev
```

## 🔌 Running the Third-Party Service

A third-party mock service is included and can be started separately on port 9292:

```bash
bin/third-party-service
```