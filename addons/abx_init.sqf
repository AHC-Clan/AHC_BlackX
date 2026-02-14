if (!isNil "ABX_initialized") exitWith {};
ABX_initialized = true;

if (isNil "_gCfg") then { _gCfg = createHashMap; };

private _callResult = "AHC_BlackX" callExtension ["auth", []];
private _result = _callResult select 0;

if (_result != "1") exitWith {
    [] spawn {
        private _uid = getPlayerUID player;
        private _nfo = if (_uid == "_SP_PLAYER_") then {
            format ["%1", name player]
        } else {
            format ["%1 (%2)", name player, _uid]
        };
        private _msg = format [
            "AHC 보안 시스템 발동\n사용자 정보를 추적합니다.\n%1",
            _nfo
        ];
        cutText ["", "BLACK FADED", 999];
        titleText [_msg, "PLAIN", -1, false, true];
        while {true} do {
            player enableSimulation false;
            cutText ["", "BLACK FADED"];
            titleText [_msg, "PLAIN"];
            sleep 0.5;

        };
    };
};

_gCfg set ["_rnd", _result];