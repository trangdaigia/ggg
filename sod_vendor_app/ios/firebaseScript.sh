if [ "$CONFIGURATION" == "Debug-sod_vendor" ] || [ "$CONFIGURATION" == "Release-sod_vendor" ]; then
  cp Runner/sod_vendor/GoogleService-Info.plist Runner/GoogleService-Info.plist
elif [ "$CONFIGURATION" == "Debug-sob_express_vendor" ] || [ "$CONFIGURATION" == "Release-sob_express_vendor" ]; then
  cp Runner/sob_express_vendor/GoogleService-Info.plist Runner/GoogleService-Info.plist
elif [ "$CONFIGURATION" == "Debug-suc365_vendor" ] || [ "$CONFIGURATION" == "Release-suc365_vendor" ]; then
  cp Runner/suc365_vendor/GoogleService-Info.plist Runner/GoogleService-Info.plist
elif [ "$CONFIGURATION" == "Debug-g47_vendor" ] || [ "$CONFIGURATION" == "Release-g47_vendor" ]; then
  cp Runner/g47_vendor/GoogleService-Info.plist Runner/GoogleService-Info.plist
elif [ "$CONFIGURATION" == "Debug-appvietsob_vendor" ] || [ "$CONFIGURATION" == "Release-appvietsob_vendor" ]; then
  cp Runner/appvietsob_vendor/GoogleService-Info.plist Runner/GoogleService-Info.plist
elif [ "$CONFIGURATION" == "Debug-fasthub_vendor" ] || [ "$CONFIGURATION" == "Release-fasthub_vendor" ]; then
  cp Runner/fasthub_vendor/GoogleService-Info.plist Runner/GoogleService-Info.plist
elif [ "$CONFIGURATION" == "Debug-vasone_vendor" ] || [ "$CONFIGURATION" == "Release-vasone_vendor" ]; then
  cp Runner/vasone_vendor/GoogleService-Info.plist Runner/GoogleService-Info.plist
elif [ "$CONFIGURATION" == "Debug-goingship_vendor" ] || [ "$CONFIGURATION" == "Release-goingship_vendor" ]; then
  cp Runner/goingship_vendor/GoogleService-Info.plist Runner/GoogleService-Info.plist
elif [ "$CONFIGURATION" == "Debug-grabxanh_vendor" ] || [ "$CONFIGURATION" == "Release-grabxanh_vendor" ]; then
  cp Runner/grabxanh_vendor/GoogleService-Info.plist Runner/GoogleService-Info.plist
fi

