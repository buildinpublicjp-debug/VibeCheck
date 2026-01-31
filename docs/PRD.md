# VibeCheck - Product Requirements Document

## Overview

**Product Name:** VibeCheck

**Tagline:** Track nothing. See everything.

**One-liner:** 入力ゼロで、積み上げが見えるライフログアプリ。

## Problem

Obsidian Daily Noteで日々を記録しているが、振り返りが面倒で成長の実感がない。HealthKitデータも散らばっていて、統合的に自分の状態を把握できない。

## Solution

Obsidian VaultとHealthKitから自動でデータを取得し、Claude AIで構造化、美しいダッシュボードで可視化する。

## Target Users

- Obsidian Daily Noteを毎日書いているユーザー
- Claude/AIツールを日常的に使っている
- 自己管理・振り返りに興味がある
- iOS/iPhoneユーザー

## Core Features (MVP)

### 1. Obsidian Vault連携
- iCloud上のObsidian Vaultフォルダを選択
- Security-Scoped Bookmarkで永続的にアクセス
- Daily Noteを自動で読み込み

### 2. HealthKit連携
- 体重、歩数、睡眠時間、心拍数を取得
- Apple Watch, Oura Ring等のデータ対応

### 3. Claude APIパース
- Daily Noteテキストを送信
- カテゴリ（workout, reading, insight等）を自動分類

### 4. ダッシュボード（Today View）
- 今日の体重、歩数、睡眠を表示
- 今日のDaily Noteハイライトを表示

### 5. タイムライン（History View）
- 週ごとにハイライトを表示
- カテゴリでフィルタ

## Technical Requirements

- iOS 17.0+
- SwiftUI + SwiftData
- MVVM with @Observable
- Claude API (Haiku 4.5)
- HealthKit

## Security

- HealthKitデータは外部送信しない
- APIキーはKeychain保存
- Obsidianテキストのみ Claude APIに送信

## Success Metrics

| 指標 | 目標 |
|------|------|
| TestFlightユーザー | 50人 |
| DAU | 100 |
| 有料転換率 | 10% |