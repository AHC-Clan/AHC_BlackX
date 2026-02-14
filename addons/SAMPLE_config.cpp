// ----- 방식 A: config.cpp에서 호출 -----

 class Extended_PostInit_EventHandlers {
     class 내_애드온_이름 {
         init = "call compile preprocessFileLineNumbers '\내_애드온_이름\abx_init.sqf'";
     };
 };

// ----- 방식 B: XEH_postInit.sqf에서 호출 -----
//
 call compile preprocessFileLineNumbers "\내_애드온_이름\abx_init.sqf";