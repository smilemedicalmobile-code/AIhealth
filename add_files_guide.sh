#!/bin/bash

echo "🔧 AIhealth 프로젝트 파일 추가 가이드"
echo "=================================="
echo ""
echo "다음 단계를 Xcode에서 실행하세요:"
echo ""
echo "1️⃣  Xcode에서 AIhealth.xcodeproj 열기"
echo "   open /Users/chaedongjoo/Developer/AIhealth/AIhealth.xcodeproj"
echo ""
echo "2️⃣  왼쪽 네비게이터에서 'AIhealth' 폴더 우클릭"
echo ""
echo "3️⃣  'Add Files to AIhealth...' 선택"
echo ""
echo "4️⃣  다음 폴더들을 하나씩 선택해서 추가:"
echo "   📁 Models/"
echo "   📁 ViewModels/"
echo "   📁 Views/"
echo "   📁 Services/"
echo "   📁 Utilities/"
echo "   📁 Theme/"
echo ""
echo "5️⃣  각 폴더 추가 시 다음 옵션 선택:"
echo "   ✅ Copy items if needed"
echo "   ✅ Create groups"
echo "   ✅ Add to targets: AIhealth"
echo ""
echo "6️⃣  모든 폴더 추가 후:"
echo "   Product → Clean Build Folder (⇧⌘K)"
echo "   Product → Build (⌘B)"
echo ""
echo "=================================="
echo ""
echo "또는 자동으로 Xcode 열기:"
read -p "Xcode를 열까요? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    open /Users/chaedongjoo/Developer/AIhealth/AIhealth.xcodeproj
    echo "✅ Xcode가 열렸습니다!"
fi
