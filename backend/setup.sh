#!/bin/bash
# DOZ Backend Setup Script
set -e

echo "Setting up DOZ Backend..."

# Install dependencies
echo "Installing dependencies..."
npm install

# Generate Prisma client
echo "Generating Prisma client..."
npx prisma generate

# Push database schema
echo "Creating database schema..."
npx prisma db push

# Seed demo data
echo "Seeding demo data..."
npm run seed

echo ""
echo "✅ DOZ Backend is ready!"
echo ""
echo "To start the server:"
echo "  npm run dev"
echo ""
echo "Demo credentials:"
echo "  Admin:  admin@doz.com / admin123"
echo "  Rider:  ahmed@example.com / rider123"
echo "  Driver: khalid.driver@example.com / driver123"
