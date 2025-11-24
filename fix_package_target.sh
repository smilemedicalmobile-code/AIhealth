#!/bin/bash

echo "🔧 Xcode 패키지 타겟 문제 해결"
echo ""
echo "다음 단계를 따라주세요:"
echo ""
echo "1️⃣ Xcode에서 프로젝트 닫기"
echo "2️⃣ 터미널에서 다음 명령 실행:"
echo ""
echo "   rm -rf ~/Library/Developer/Xcode/DerivedData/AIhealth-*"
echo ""
echo "3️⃣ Xcode 다시 열기"
echo "4️⃣ File → Packages → Reset Package Caches"
echo "5️⃣ Product → Clean Build Folder (Shift + Cmd + K)"
echo ""
echo "그 다음 다시 패키지 추가 시도"
echo ""
echo "========================================="
echo "현재 프로젝트 구조:"
grep "PBXFileSystemSynchronizedRootGroup" /Users/chaedongjoo/Developer/AIhealth/AIhealth.xcodeproj/project.pbxproj > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Xcode 15 새로운 프로젝트 포맷 사용 중"
    echo ""
    echo "이 경우 추가 해결 방법:"
    echo "- 패키지를 추가할 때 'Add to Project' 대신 'Add to Target' 직접 선택"
    echo "- 또는 Package.swift를 직접 편집"
else
    echo "✅ 일반 프로젝트 포맷"
fi
echo "========================================="
