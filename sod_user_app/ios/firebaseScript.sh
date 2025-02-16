if [ "$CONFIGURATION" == "Debug-sod_user" ] || [ "$CONFIGURATION" == "Release-sod_user" ]; then
  cp Runner/sod_user/GoogleService-Info.plist Runner/GoogleService-Info.plist
elif [ "$CONFIGURATION" == "Debug-sob_express" ] || [ "$CONFIGURATION" == "Release-sob_express" ]; then
  cp Runner/sob_express/GoogleService-Info.plist Runner/GoogleService-Info.plist
elif [ "$CONFIGURATION" == "Debug-suc365_user" ] || [ "$CONFIGURATION" == "Release-suc365_user" ]; then
  cp Runner/suc365_user/GoogleService-Info.plist Runner/GoogleService-Info.plist
elif [ "$CONFIGURATION" == "Debug-g47_user" ] || [ "$CONFIGURATION" == "Release-g47_user" ]; then
  cp Runner/g47_user/GoogleService-Info.plist Runner/GoogleService-Info.plist
elif [ "$CONFIGURATION" == "Debug-appvietsob_user" ] || [ "$CONFIGURATION" == "Release-appvietsob_user" ]; then
  cp Runner/appvietsob_user/GoogleService-Info.plist Runner/GoogleService-Info.plist
elif [ "$CONFIGURATION" == "Debug-vasone" ] || [ "$CONFIGURATION" == "Release-vasone" ]; then
  cp Runner/vasone/GoogleService-Info.plist Runner/GoogleService-Info.plist
elif [ "$CONFIGURATION" == "Debug-fasthub_user" ] || [ "$CONFIGURATION" == "Release-fasthub_user" ]; then
  cp Runner/fasthub_user/GoogleService-Info.plist Runner/GoogleService-Info.plist
elif [ "$CONFIGURATION" == "Debug-goingship" ] || [ "$CONFIGURATION" == "Release-goingship" ]; then
  cp Runner/goingship/GoogleService-Info.plist Runner/GoogleService-Info.plist
elif [ "$CONFIGURATION" == "Debug-grabxanh" ] || [ "$CONFIGURATION" == "Release-grabxanh" ]; then
  cp Runner/grabxanh/GoogleService-Info.plist Runner/GoogleService-Info.plist
elif [ "$CONFIGURATION" == "Debug-inux" ] || [ "$CONFIGURATION" == "Release-inux" ]; then
  cp Runner/inux/GoogleService-Info.plist Runner/GoogleService-Info.plist
fi

