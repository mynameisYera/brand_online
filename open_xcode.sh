#!/bin/bash

# Скрипт для открытия Xcode проекта
# Script to open Xcode project

echo "Открываю Xcode проект..."
echo "Opening Xcode project..."

open ios/Runner.xcworkspace

echo ""
echo "После открытия Xcode:"
echo "1. File → New → File → StoreKit Configuration File"
echo "2. Создайте продукт с ID: restart_month"
echo "3. Edit Scheme → Run → Options → выберите .storekit файл"
echo ""
echo "См. QUICK_FIX_STOREKIT.md для подробной инструкции"

