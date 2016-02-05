#include <a_samp>
#include <a_mysql>
#include <sscanf>
#include <dc_cmd>
#include <foreach>
#include <streamer>
#include <flycam>
#include <dc_anims>
#include <core/database>

#define WHITE												0xFFFFFFFF
#define	GREEN												0x33FF00FF
#define YELLOW												0xFFFF33FF
#define BLUE												0x1976D2FF
#define DEEP_ORANGE 										0xFF5722FF
#define GRAY 												0x9E9E9EFF

#define STREAMER_OBJECT_DISTANCE							(300.00)
#define STREAMER_SMALL_OBJECT_DISTANCE						(300.00)
#define STREAMER_OBJECT_DRAW_DISTANCE						(300.00)
#define MAX_TRAYS_EAT										(126)

#define array:%0[%1]; \
	goto _noinit_%0; new %0[%1]; _noinit_%0:

new player_gun_patr[MAX_PLAYERS][9];	
new bool: player_spawning[MAX_PLAYERS];

stock legal__GivePlayerWeapon(playerid, ammo, patr)
{
	switch(ammo)
	{
		case WEAPON_NITESTICK:				player_gun_patr[playerid][0] += patr; 					// 3 Nightstick
		case WEAPON_BAT:					player_gun_patr[playerid][0] += patr;					// 5 Baseball Bat
		case WEAPON_KATANA:					player_gun_patr[playerid][0] += patr;					// 8 Katana
		case WEAPON_SILENCED:				player_gun_patr[playerid][1] += patr;					// 23 Silenced 9mm
		case WEAPON_DEAGLE:					player_gun_patr[playerid][1] += patr;					// 24 Desert Eagle
		case WEAPON_SHOTGUN:				player_gun_patr[playerid][2] += patr;					// 25 Shotgun
		case WEAPON_MP5:					player_gun_patr[playerid][3] += patr;					// 29 MP5
		case WEAPON_AK47:					player_gun_patr[playerid][4] += patr;					// 30 AK-47
		case WEAPON_M4:						player_gun_patr[playerid][4] += patr;					// 31 M4
		case WEAPON_RIFLE:					player_gun_patr[playerid][5] += patr;					// 33 Country Rifle
		case WEAPON_SNIPER:					player_gun_patr[playerid][5] += patr;					// 34 Sniper Rifle
		case WEAPON_FIREEXTINGUISHER:		player_gun_patr[playerid][6] += patr;					// 42 Fire Extinguisher
		case WEAPON_CAMERA:					player_gun_patr[playerid][6] += patr;					// 43 Camera
		case WEAPON_PARACHUTE:				player_gun_patr[playerid][7] += patr;					// 46 Parachute
		case WEAPON_DILDO:					player_gun_patr[playerid][8] += patr;					// 10 Purple Dildo
		case WEAPON_DILDO2:					player_gun_patr[playerid][8] += patr;					// 11 Dildo
		case WEAPON_VIBRATOR:				player_gun_patr[playerid][8] += patr;					// 12 Vibrator
		case WEAPON_VIBRATOR2:				player_gun_patr[playerid][8] += patr;					// 13 Silver Vibrator	
		case WEAPON_FLOWER:					player_gun_patr[playerid][8] += patr;					// 14 Flowers
	}
    return GivePlayerWeapon(playerid, ammo, patr);	
}

#if defined _ALS_GivePlayerWeapon
    #undef    GivePlayerWeapon
#else
    #define    _ALS_GivePlayerWeapon
#endif
#define    GivePlayerWeapon    legal__GivePlayerWeapon

stock legal__ResetPlayerWeapons(playerid)
{
	for(new i; i < sizeof(player_gun_patr); i ++)
		player_gun_patr[playerid][i] = 0;
    return ResetPlayerWeapons(playerid);	
}

#if defined _ALS_ResetPlayerWeapons
    #undef    ResetPlayerWeapons
#else
    #define    _ALS_ResetPlayerWeapons
#endif
#define    ResetPlayerWeapons    legal__ResetPlayerWeapons

stock spd__SpawnPlayer(playerid)
{
	player_spawning[playerid] = true;
    return SpawnPlayer(playerid);
}
#if defined _ALS_SpawnPlayer
    #undef    SpawnPlayer
#else
    #define    _ALS_SpawnPlayer
#endif
#define    SpawnPlayer    spd__SpawnPlayer 

stock spd__TogglePlayerSpectating(playerid, toggle)
{
	if(toggle == 0)
		player_spawning[playerid] = true;
    return TogglePlayerSpectating(playerid, toggle);
}
#if defined _ALS_TogglePlayerSpectating
    #undef    TogglePlayerSpectating
#else
    #define    _ALS_TogglePlayerSpectating
#endif
#define    TogglePlayerSpectating    spd__TogglePlayerSpectating

public OnPlayerSpawn(playerid)
{
    if(player_spawning[playerid] == false)
	{
		SendClientMessage(playerid, WHITE, !"Обнаружено использование чит-программ {76FF03}(hdcode: 141518)");
		SendClientMessage(playerid, WHITE, !"Используйте {76FF03}/q(quit){ffffff} для выхода из игры");
		KickPlayer(playerid);
	}
	player_spawning[playerid] = false;
#if defined spd__OnPlayerSpawn
    return spd__OnPlayerSpawn(playerid);
#endif
}
#if defined _ALS_OnPlayerSpawn
    #undef    OnPlayerSpawn
#else
    #define    _ALS_OnPlayerSpawn
#endif
#define    OnPlayerSpawn    spd__OnPlayerSpawn
#if defined spd__OnPlayerSpawn
forward spd__OnPlayerSpawn(playerid);
#endif  

public OnPlayerDeath(playerid, killerid, reason)
{
	player_spawning[playerid] = true;
#if defined spd__OnPlayerDeath
    return spd__OnPlayerDeath(playerid, killerid, reason);
#endif
}
#if defined _ALS_OnPlayerDeath
    #undef    OnPlayerDeath
#else
    #define    _ALS_OnPlayerDeath
#endif
#define    OnPlayerDeath    spd__OnPlayerDeath
#if defined spd__OnPlayerDeath
forward spd__OnPlayerDeath(playerid, killerid, reason);
#endif 

forward IsPlayerAccounts(playerid);
forward PlayerKick(playerid);
forward LoadPlayerAccounts(playerid);

new server_database;
new bool: server_approachability;
new Text: server_logotype;
new Text: server_skin_show[5];
new player_actor_show[MAX_PLAYERS];
new player_actor_skin_id[MAX_PLAYERS];
new bool: player_logged[MAX_PLAYERS];
new player_help_checkpoint[MAX_PLAYERS][2];
new player_pickup_eat[4];
new eat_player[MAX_PLAYERS];
new player_timer[MAX_PLAYERS];
new pickup_building_job[2];
new job_building[MAX_PLAYERS];
new job_building_money[MAX_PLAYERS];
new job_building_bag[MAX_PLAYERS];
new warehouse_total_ammo;
new Text3D: warehouse_text;
new SetTypeCheckpoint[MAX_PLAYERS];
new pickup_plant_job[3];
new job_plant[MAX_PLAYERS];
new job_plant_money[MAX_PLAYERS];
new bool: job_plant_metal[MAX_PLAYERS];
new job_plant_pickup[MAX_PLAYERS][11];
new job_plant_pickup_give[MAX_PLAYERS];
new bool: table_job_plant_used[10];
new table_job_plant_object[10];
new plant_fuel;
new plant_metall;
new plant_total_product;
new Text3D: plant_info_products;
new Text3D: plant_info_store;
new Text3D: plant_info_street_store;
new pickup_city_hall[10];
new player_table_plant[MAX_PLAYERS];
new tank[4];
new Text3D: tank_info_1;
new Text3D: tank_info_2;
new Text3D: tank_info_3;
new Text3D: tank_info_4;

enum 
{ 
	NONE,
	JOB_BUILDING_TAKE,
	JOB_BUILDING_PUT,
	JOB_PLANT_TAKE,
	JOB_PLANT_PUT
} 

enum Accounts
{
	Name[MAX_PLAYER_NAME],
	Password[20],
	IP[16],
	Money,
	Skin,
	Sex,
	Admin,
	Level,
	Exp,
	Float: Health
};
new PlayerInfo[MAX_PLAYERS][Accounts];

stock spd__SetPlayerHealth(playerid, Float: health)
{
	if(health >= 100.00)
		health = 99.00;
	if(health < 15)
		health = 15;
	PlayerInfo[playerid][Health] = health;
	return SetPlayerHealth(playerid, Float: health);
}
#if defined _ALS_SetPlayerHealth
    #undef    SetPlayerHealth
#else
    #define    _ALS_SetPlayerHealth
#endif
#define    SetPlayerHealth    spd__SetPlayerHealth

enum Reconnect
{
	IP[16],
	TimeQuit,
}
new ReconnectInfo[MAX_PLAYERS][Reconnect];

enum Pickup
{
	pickup_id,
	pickup_time
}
new PickupInfo[MAX_PLAYERS][Pickup];

enum eat_
{
	eat_id,
	eat_status,
	Float: eat_x,
	Float: eat_y,
	Float: eat_z,
	Float: eat_angle,
	eat_interior,
	eat_virtualworld,
	eat_time_drop,
	Text3D: eat_text[32]
};

new eat[MAX_TRAYS_EAT][eat_];

main()
{

}

enum veh_tank_
{
	tank_id,
	tank_fuel
}

new TankInfo[6][veh_tank_];

new car_plant[6];
new Text3D: text_car_plant[3];
new plant_tank_cude;

public OnGameModeInit()
{
	plant_tank_cude = CreateDynamicCube(288.3424, 1336.1122, 4.5633, 110.5151, 1484.7823, 50.4114, 0, 0, -1);
	TankInfo[0][tank_id] = AddStaticVehicleEx(514, -1.7463, -325.8507, 6.4274, 90.0000, 162, 162, 420000);
	TankInfo[1][tank_id] = AddStaticVehicleEx(514, -1.7453, -329.2849, 6.4274, 90.0000, 162, 162, 420000);
	TankInfo[2][tank_id] = AddStaticVehicleEx(514, -1.7453, -332.6799, 6.4274, 90.0000, 162, 162, 420000);
	
	TankInfo[3][tank_id] = AddStaticVehicleEx(584, -61.7934, -310.9330, 6.547, 270.0000, 162, 162, 420000);
	TankInfo[4][tank_id] = AddStaticVehicleEx(584, -61.7934, -314.2799, 6.547, 270.0000, 162, 162, 420000);
	TankInfo[5][tank_id] = AddStaticVehicleEx(584, -61.7903, -317.8372, 6.547, 270.0000, 162, 162, 420000);
	text_car_plant[0] = CreateDynamic3DTextLabel(!"Цистерна\nЗалито {33FF00}0{ffffff}/{33FF00}5000{ffffff} литров топлива", WHITE, 0.00, 0.00, -1000.00, 30.00, INVALID_PLAYER_ID, TankInfo[3][tank_id], 1, 0, 0, -1, 30.0);
	text_car_plant[1] = CreateDynamic3DTextLabel(!"Цистерна\nЗалито {33FF00}0{ffffff}/{33FF00}5000{ffffff} литров топлива", WHITE, 0.00, 0.00, -1000.00, 30.00, INVALID_PLAYER_ID, TankInfo[4][tank_id], 1, 0, 0, -1, 30.0);
	text_car_plant[2] = CreateDynamic3DTextLabel(!"Цистерна\nЗалито {33FF00}0{ffffff}/{33FF00}5000{ffffff} литров топлива", WHITE, 0.00, 0.00, -1000.00, 30.00, INVALID_PLAYER_ID, TankInfo[5][tank_id], 1, 0, 0, -1, 30.0);
	AddStaticVehicleEx(455, -95.7184, -356.8881, 1.4297, 340.8386, 162, 1, 6000000);
	
	// Мэрия
	pickup_city_hall[0] = CreateDynamicPickup(1318, 23, 1481.0433, -1772.1016, 18.7958, 0, 0, -1, 50.00);
	pickup_city_hall[1] = CreateDynamicPickup(1318, 23, -2766.2998, 375.5755, 6.3347, 0, 0, -1, 50.00);
	pickup_city_hall[2] = CreateDynamicPickup(1318, 23, 2388.9963, 2465.9746, 10.8203, 0, 0, -1, 50.00);
	pickup_city_hall[3] = CreateDynamicPickup(1318, 23, 256.9692, 166.7085, 1087.5798, -1, 2, -1, 50.00);
	pickup_city_hall[4] = CreateDynamicPickup(1318, 23, 235.0335, 186.9513, 1087.5829, -1, 2, -1, 50.00);
	pickup_city_hall[5] = CreateDynamicPickup(1318, 23, 1413.2118, -1790.4736, 15.4356, 0, 0, -1, 50.00);
	pickup_city_hall[6] = CreateDynamicPickup(1318, 23, -2800.1472, 375.6006, 6.3359, 0, 0, -1, 50.00);
	pickup_city_hall[7] = CreateDynamicPickup(1318, 23, 2516.7192, 2447.5925, 11.0313, 0, 0, -1, 50.00);
	pickup_city_hall[8] = CreateDynamicPickup(1318, 23, 216.7142, 171.5713, 1093.3956, -1, 2, -1, 50.00);
	pickup_city_hall[9] = CreateDynamicPickup(1318, 23, 220.7790, 159.8506, 1087.5784, -1, 2, -1, 50.00);
	CreateDynamic3DTextLabel(!"Мэрия\nLos Santos", BLUE, 1481.0433, -1772.1016, 18.7958 + 1, 7, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0, -1, 7);
	CreateDynamic3DTextLabel(!"Мэрия\nSan Fierro", BLUE, -2766.2998, 375.5755, 6.3347 + 1, 7, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, 0, 0, 7);
	CreateDynamic3DTextLabel(!"Мэрия\nLas Venturas", BLUE, 2388.9963, 2465.9746, 10.8203 + 1, 7, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, 0, 0, 7);
	CreateDynamic3DTextLabel(!"Выход", BLUE, 256.9692, 166.7085, 1087.5798 + 1, 7, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, 2, -1, 7);
	CreateDynamic3DTextLabel(!"Выход\nна задний двор", BLUE, 235.0335, 186.9513, 1087.5829 + 1, 7, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, 2, -1, 7);
	CreateDynamic3DTextLabel(!"Вход", BLUE, 1413.2118, -1790.4736, 15.4356 + 1, 7, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0, -1, 7);
	CreateDynamic3DTextLabel(!"Вход", BLUE, -2800.1472, 375.6006, 6.3359 + 1, 7, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0, -1, 7);
	CreateDynamic3DTextLabel(!"Вход", BLUE, 2516.7192, 2447.5925, 11.0313 + 1, 7, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0, -1, 7);
	CreateDynamic3DTextLabel(!"Cлужебный вход", BLUE, 216.7142, 171.5713, 1093.3956 + 1, 7, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, 2, -1, 7);
	CreateDynamic3DTextLabel(!"Cлужебный выход", BLUE, 220.7790, 159.8506, 1087.5784 + 1, 7, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, 2, -1, 7);
	 
	// Подносы с бесплатной едой (ЖДЛС, Автовокзал)
	player_pickup_eat[0] = CreateDynamicPickup(2821, 2, 1766.1940, -1887.0121, 13.3541, 0, 0, -1, 300.00);
	player_pickup_eat[1] = CreateDynamicPickup(2821, 2, 1163.5424, -1765.5259, 13.4228, 0, 0, -1, 300.00);
	player_pickup_eat[2] = CreateDynamicPickup(2821, 2, -79.2385, -301.0435, 1.4219 - 1, 0, 0, -1, 300.00);
	player_pickup_eat[3] = CreateDynamicPickup(2821, 2, 2706.0410, 911.0882, 10.7732 - 0.3, 0, 0, -1, 300.00);
	CreateDynamic3DTextLabel(!"Бесплатная еда", BLUE, 1163.5424, -1765.5259, 13.6228 + 1.00, 4.00, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0, -1, 4.00);
	CreateDynamic3DTextLabel(!"Бесплатная еда", BLUE, 1766.1940, -1887.0121, 13.5541 + 1.00, 4.00, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0, -1, 4.00);
	CreateDynamic3DTextLabel(!"Бесплатная еда", BLUE, -79.2385, -301.0435, 1.4219 + 1.00, 4.00, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0, -1, 4.00);
	CreateDynamic3DTextLabel(!"Бесплатная еда", BLUE, 2706.0410, 911.0882, 10.7732 + 1.00, 4.00, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0, -1, 4.00);
		
	// Cтройка
	pickup_building_job[0] = CreateDynamicPickup(1275, 23, 2700.5313, 908.6485, 10.6778, 0, 0, -1, 300.00);
	pickup_building_job[1] = CreateDynamicPickup(1239, 2, 2718.6619, 864.6910, 10.8984, 0, 0, -1, 300.00);
	CreateDynamicMapIcon(2700.5313, 908.6485, 10.6778, 11, 0xFFFFFFFF, 0, 0, -1, 170.0, MAPICON_LOCAL);
	CreateDynamic3DTextLabel(!"Трудоустройство", YELLOW, 2700.5313, 908.6485, 10.6778, 6.00, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0, -1, 6.00);
	CreateDynamic3DTextLabel(!"Информация по работе", BLUE, 2718.6619, 864.6910, 10.8984, 4.00, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0, -1, 4.00);
	CreateDynamic3DTextLabel(!"Склад для мешков", YELLOW, 2622.9531, 800.3627, 10.9545 + 2.00, 40.00, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0, -1, 40.00);

	// Завод по производству заготовок
	pickup_plant_job[0] = CreateDynamicPickup(1318, 23, -86.2609, -299.3630, 2.7646, 0, 0, -1, 300.00);
	pickup_plant_job[1] = CreateDynamicPickup(1318, 23, 32.0761, 2.9000, 1001.6033, 3, 3, -1, 300.00);
	pickup_plant_job[2] = CreateDynamicPickup(1275, 23, 31.3329, -12.8130, 1001.6033, 3, 3, -1, 300.00);
	CreateDynamic3DTextLabel(!"Производственный\nцех", BLUE, -86.2609, -299.3630, 2.7646 + 1, 7, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0, -1, 7);
	CreateDynamic3DTextLabel(!"Выход", BLUE, 32.0761, 2.9000, 1001.6033 + 1, 7, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 3, 3, -1, 7);
	CreateDynamic3DTextLabel(!"Трудоустройство", YELLOW, 31.3329, -12.8130, 1001.6033 + 2, 7, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 3, 3, -1, 7);
		
	DisableInteriorEnterExits();
	LimitPlayerMarkerRadius(20.0);
	SetNameTagDrawDistance(20.0);
	SendRconCommand(!"hostname Forest RolePlay | Закрытое бета тестрование");
	SendRconCommand(!"language Russian/Русский");
	SendRconCommand(!"password null");
	SetGameModeText(!"Release 1.00");
	MySQL_Connect();
	SetTimer(!"@ServerTime", 1000, false);
	SetTimer(!"EatDelete", 300000, true);
	DisableInteriorEnterExits();
	
	CreateDynamic3DTextLabel(!"Помощь по игре", BLUE, 1139.4917, -1761.4667, 13.5951 + 1.00, 4.00, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0, -1, 4.00);
	CreateDynamic3DTextLabel(!"Помощь по игре", BLUE, 1762.0842, -1885.9574, 13.5551 + 1.00, 4.00, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0, -1, 4.00);
		
	server_logotype = TextDrawCreate(580.952209, 1.000005, !"FOREST_RP");
	TextDrawLetterSize(server_logotype, 0.263660, 1.529999);
	TextDrawAlignment(server_logotype, 1);
	TextDrawColor(server_logotype, 1996424191);
	TextDrawSetShadow(server_logotype, 0);
	TextDrawBackgroundColor(server_logotype, 255);
	TextDrawFont(server_logotype, 2);
	TextDrawSetProportional(server_logotype, 1);
	
	server_skin_show[0] = TextDrawCreate(533.303344, 185.000000, !"usebox");
	TextDrawLetterSize(server_skin_show[0], 0.000000, 12.943882);
	TextDrawTextSize(server_skin_show[0], 444.500732, 0.000000);
	TextDrawAlignment(server_skin_show[0], 1);
	TextDrawColor(server_skin_show[0], 0);
	TextDrawUseBox(server_skin_show[0], true);
	TextDrawBoxColor(server_skin_show[0], 102);
	TextDrawSetShadow(server_skin_show[0], 0);
	TextDrawSetOutline(server_skin_show[0], 0);
	TextDrawBackgroundColor(server_skin_show[0], 1415325951);
	TextDrawFont(server_skin_show[0], 0);

	server_skin_show[1] = TextDrawCreate(451.510009, 185.330001, !"CHOOSE_SKIN");
	TextDrawLetterSize(server_skin_show[1], 0.289999, 1.500000);
	TextDrawTextSize(server_skin_show[1], -98.389450, -13.999999);
	TextDrawAlignment(server_skin_show[1], 1);
	TextDrawColor(server_skin_show[1], -1);
	TextDrawUseBox(server_skin_show[1], true);
	TextDrawBoxColor(server_skin_show[1], 0);
	TextDrawSetShadow(server_skin_show[1], 0);
	TextDrawSetOutline(server_skin_show[1], 0);
	TextDrawBackgroundColor(server_skin_show[1], 51);
	TextDrawFont(server_skin_show[1], 2);
	TextDrawSetProportional(server_skin_show[1], 1);

	server_skin_show[2] = TextDrawCreate(489.700012, 215.332992, !"NEXT");
	TextDrawLetterSize(server_skin_show[2], 0.500000, 1.500000);
	TextDrawTextSize(server_skin_show[2], 12.397895, 42.583301);
	TextDrawAlignment(server_skin_show[2], 2);
	TextDrawColor(server_skin_show[2], -1);
	TextDrawUseBox(server_skin_show[2], true);
	TextDrawBoxColor(server_skin_show[2], 0);
	TextDrawSetShadow(server_skin_show[2], 0);
	TextDrawSetOutline(server_skin_show[2], 0);
	TextDrawBackgroundColor(server_skin_show[2], 16711935);
	TextDrawFont(server_skin_show[2], 2);
	TextDrawSetSelectable(server_skin_show[2], true);

	server_skin_show[3] = TextDrawCreate(460.049987, 235.332992, !"PREVIOUS");
	TextDrawLetterSize(server_skin_show[3], 0.300000, 1.500000);
	TextDrawTextSize(server_skin_show[3], 516.778991, 12.916671);
	TextDrawAlignment(server_skin_show[3], 1);
	TextDrawColor(server_skin_show[3], 0x757575FF);
	TextDrawUseBox(server_skin_show[3], true);
	TextDrawBoxColor(server_skin_show[3], 0);
	TextDrawSetShadow(server_skin_show[3], 0);
	TextDrawSetOutline(server_skin_show[3], 0);
	TextDrawBackgroundColor(server_skin_show[3], 51);
	TextDrawFont(server_skin_show[3], 2);
	TextDrawSetProportional(server_skin_show[3], 1);
	TextDrawSetSelectable(server_skin_show[3], false);

	server_skin_show[4] = TextDrawCreate(465.649993, 270.333007, !"PLAY");
	TextDrawLetterSize(server_skin_show[4], 0.449999, 1.600000);
	TextDrawTextSize(server_skin_show[4], 510.688140, 9.333333);
	TextDrawAlignment(server_skin_show[4], 1);
	TextDrawColor(server_skin_show[4], 7399167);
	TextDrawUseBox(server_skin_show[4], true);
	TextDrawBoxColor(server_skin_show[4], 0);
	TextDrawSetShadow(server_skin_show[4], 0);
	TextDrawSetOutline(server_skin_show[4], 0);
	TextDrawBackgroundColor(server_skin_show[4], 51);
	TextDrawFont(server_skin_show[4], 2);
	TextDrawSetProportional(server_skin_show[4], 1);
	TextDrawSetSelectable(server_skin_show[4], true);
	
	new tempobject;
	
	// ЖДЛС, Автовокзал
	tempobject = CreateDynamicObject(1340, 1767.199, -1886.099, 13.699, 0.000, 0.000, 225.00, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 6,	3080, !"adjumpx", !"jumptop1_64", 0);
	CreateDynamicObject(1280, 1758.000, -1906.801, 12.967, 0.00, 0.00, 270.00, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1280, 1761.300, -1906.801, 12.967, 0.00, 0.00, 270.00, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1280, 1764.600, -1906.801, 12.967, 0.00, 0.00, 270.00, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1280, 1767.900, -1906.801, 12.967, 0.00, 0.00, 270.00, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(994, 1769.430, -1906.994, 12.560, 0.00, 0.00, 90.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(994, 1769.430, -1899.639, 12.560, 0.00, 0.00, 90.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(994, 1769.430, -1891.922, 12.560, 0.00, 0.00, 90.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(997, 1810.762, -1881.327, 12.583, 0.00, 0.00, 270.00, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(997, 1811.087, -1895.694, 12.583, 0.00, 0.00, 270.00, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(713, 1159.166, -1725.974, 12.883, 0.00, 0.00, 155.478, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(713, 1129.964, -1726.103, 12.876, 0.00, 0.00, 155.478, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(983, 1164.935, -1725.488, 13.576, 0.00, 0.00, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(982, 1152.125, -1722.306, 13.630, 0.00, 0.00, 90.00, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(982, 1072.203, -1777.182, 13.225, 0.00, 0.00, 90.00, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(982, 1072.094, -1735.888, 13.343, 0.00, 0.00, 89.74, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(984, 1059.202, -1767.858, 13.208, 0.00, 0.00, 0.00, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(982, 1059.259, -1748.650, 13.343, 0.00, 0.00, 0.00, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(996, 1177.348, -1730.864, 13.326, 0.00, 0.00, 90.00, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(996, 1177.364, -1741.314, 13.326, 0.00, 0.00, 90.00, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(996, 1177.350, -1751.312, 13.326, 0.00, 0.00, 90.00, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(996, 1177.401, -1761.427, 13.326, 0.00, 0.00, 90.00, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(996, 1177.385, -1771.849, 13.326, 0.00, 0.00, 90.00, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(996, 1177.389, -1782.058, 13.326, 0.00, 0.00, 90.00, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1280, 1161.191, -1769.791, 15.994, 0.00, 0.00, 0.00, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1280, 1140.665, -1767.661, 16.000, 0.00, 0.00, 90.00, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(994, 1158.677, -1750.906, 12.569, 0.00, 0.00, 0.00, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(994, 1150.637, -1750.896, 12.569, 0.00, 0.00, 0.00, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(994, 1142.499, -1750.878, 12.569, 0.00, 0.00, 0.00, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(994, 1141.004, -1750.856, 12.569, 0.00, 0.00, 270.00, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(994, 1164.916, -1752.578, 12.569, 0.00, 0.00, 270.00, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(994, 1164.921, -1760.676, 12.569, 0.00, 0.00, 270.00, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(994, 1164.906, -1766.927, 12.569, 0.00, 0.00, 180.00, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1231, 1759.144, -1920.357, 15.303, 0.00, 0.00, 0.00, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1231, 1759.113, -1927.902, 15.303, 0.00, 0.00, 0.00, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1289, 1768.944, -1895.064, 13.142, 0.00, 0.00, 90.00, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1287, 1768.939, -1895.713, 13.142, 0.00, 0.00, 90.00, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1216, 1767.442, -1884.161, 13.246, 0.00, 0.00, 0.00, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1216, 1768.041, -1884.146, 13.246, 0.00, 0.00, 0.00, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	
	// Стройка
	tempobject = CreateDynamicObject(1684, 2697.113, 911.087, 11.157, 0.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 3, 18646, !"matcolours", !"orange", -16776961);
	SetDynamicObjectMaterial(tempobject, 4, 18996, !"mattextures", !"sampwhite", 0);
	SetDynamicObjectMaterial(tempobject, 5, 18996, !"mattextures", !"sampwhite", 0);
	SetDynamicObjectMaterial(tempobject, 6, 18996, !"mattextures", !"sampwhite", 0);
	SetDynamicObjectMaterial(tempobject, 7, 18996, !"mattextures", !"sampwhite", -1);
	CreateDynamicObject(1685, 2703.300, 910.099, 10.399, 0.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1685, 2703.300, 912.000, 10.399, 0.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1685, 2677.600, 864.299, 10.699, 0.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1685, 2675.100, 864.299, 10.699, 0.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1685, 2672.399, 864.200, 10.699, 0.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1685, 2584.600, 785.500, 10.699, 0.000, 0.000, 270.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1685, 2673.900, 864.099, 12.199, 0.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1685, 2584.500, 788.099, 10.699, 0.000, 0.000, 270.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1685, 2584.500, 790.700, 10.699, 0.000, 0.000, 270.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1685, 2586.699, 785.400, 10.699, 0.000, 0.000, 270.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1685, 2588.699, 785.400, 10.699, 0.000, 0.000, 270.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2060, 2677.500, 865.700, 10.100, 0.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2060, 2676.199, 865.700, 10.100, 0.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2060, 2676.899, 866.299, 10.100, 0.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2060, 2675.600, 866.299, 10.100, 0.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2060, 2675.000, 865.700, 10.100, 0.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2060, 2678.100, 866.299, 10.100, 0.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2060, 2674.699, 866.599, 10.100, 0.000, 0.000, 90.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2060, 2674.699, 866.599, 10.300, 0.000, 0.000, 90.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2060, 2586.699, 786.799, 10.100, 0.000, 0.000, 180.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2060, 2676.199, 865.599, 10.300, 0.000, 0.000, 179.994, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2060, 2677.500, 865.599, 10.300, 0.000, 0.000, 179.994, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2060, 2677.500, 865.599, 10.500, 0.000, 0.000, 179.994, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2060, 2675.600, 866.299, 10.300, 0.000, 0.000, 179.994, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2060, 2586.699, 786.799, 10.300, 0.000, 0.000, 179.994, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2060, 2588.000, 786.700, 10.100, 0.000, 0.000, 179.994, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2060, 2588.000, 786.700, 10.300, 0.000, 0.000, 179.994, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2060, 2586.100, 787.799, 10.100, 0.000, 0.000, 239.994, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2060, 2586.100, 787.799, 10.300, 0.000, 0.000, 239.990, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1685, 2585.300, 798.900, 10.699, 0.000, 0.000, 270.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1685, 2585.300, 798.900, 12.199, 0.000, 0.000, 270.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1685, 2587.199, 798.900, 12.199, 0.000, 0.000, 270.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1685, 2587.199, 798.900, 10.699, 0.000, 0.000, 270.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(5130, 2620.899, 825.200, 6.900, 0.000, 0.000, 45.750, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(994, 2717.100, 854.900, 9.899, 0.000, 0.000, 90.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(994, 2717.100, 846.299, 9.899, 0.000, 0.000, 90.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1391, 2682.600, 806.799, 42.500, 0.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	tempobject = CreateDynamicObject(1388, 2682.699, 807.000, 54.70, 0.000, 0.000, 269.996, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 4, 16644, !"a51_detailstuff", !"roucghstonebrtb", 0);
	SetDynamicObjectMaterial(tempobject, 6, 16644, !"a51_detailstuff", !"roucghstonebrtb", 0);
	CreateDynamicObject(1436, 2612.899, 801.700, 11.500, 0.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1436, 2615.199, 801.700, 11.500, 0.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(5130, 2658.600, 866.299, 7.000, 0.000, 0.000, 133.500, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1698, 2665.199, 866.099, 9.899, 0.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1698, 2666.500, 866.099, 9.899, 0.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1698, 2667.800, 866.099, 9.899, 0.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(983, 2681.699, 856.200, 10.500, 180.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(983, 2681.699, 862.599, 10.500, 179.994, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(983, 2681.699, 869.000, 10.500, 179.994, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(983, 2678.500, 872.200, 10.500, 179.994, 0.000, 90.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(983, 2672.100, 872.200, 10.500, 179.994, 0.000, 90.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1685, 2680.199, 873.299, 10.699, 0.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1685, 2678.300, 873.299, 10.699, 0.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1685, 2676.199, 873.299, 10.699, 0.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1685, 2679.199, 873.400, 12.199, 0.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1685, 2677.199, 873.299, 12.199, 0.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(983, 2678.500, 853.000, 10.500, 179.994, 0.000, 270.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(983, 2672.100, 853.000, 10.500, 179.994, 0.000, 270.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3504, 2674.100, 873.299, 11.300, 0.000, 0.000, 359.863, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3504, 2672.399, 873.299, 11.300, 0.000, 0.000, 359.863, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3504, 2670.699, 873.299, 11.300, 0.000, 0.000, 359.863, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1519, 2718.399, 784.599, 11.100, 0.000, 0.000, 90.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1519, 2718.399, 787.099, 11.100, 0.000, 0.000, 90.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1519, 2718.399, 789.599, 11.100, 0.000, 0.000, 90.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1519, 2718.399, 792.099, 11.100, 0.000, 0.000, 90.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1519, 2718.399, 794.599, 11.100, 0.000, 0.000, 90.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1519, 2718.399, 797.099, 11.100, 0.000, 0.000, 90.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1519, 2718.399, 799.599, 11.100, 0.000, 0.000, 90.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1519, 2718.399, 802.099, 11.100, 0.000, 0.000, 90.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1519, 2718.399, 804.599, 11.100, 0.000, 0.000, 90.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1519, 2718.399, 807.099, 11.100, 0.000, 0.000, 90.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1519, 2718.399, 809.599, 11.100, 0.000, 0.000, 90.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1519, 2718.399, 812.099, 11.100, 0.000, 0.000, 90.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3399, 2674.300, 833.599, 8.000, 0.000, 0.000, 180.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	
	tempobject = CreateDynamicObject(19435, 2717.149, 867.479, 10.873, 90.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 14789, !"ab_sfgymmain", !"ab_panelWall1", 0);
	tempobject = CreateDynamicObject(19435, 2717.149, 887.356, 10.873, 90.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 14789, !"ab_sfgymmain", !"ab_panelWall1", 0);
	tempobject = CreateDynamicObject(19435, 2717.149, 908.203, 10.873, 90.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 14789, !"ab_sfgymmain", !"ab_panelWall1", 0);
	tempobject = CreateDynamicObject(19435, 2717.149, 836.942, 10.873, 90.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 14789, !"ab_sfgymmain", !"ab_panelWall1", 0);
	tempobject = CreateDynamicObject(19435, 2717.149, 819.883, 10.873, 90.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 14789, !"ab_sfgymmain", !"ab_panelWall1", 0);
	tempobject = CreateDynamicObject(19435, 2717.149, 797.906, 10.873, 90.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 14789, !"ab_sfgymmain", !"ab_panelWall1", 0);
	tempobject = CreateDynamicObject(19482, 2717.254, 868.865, 10.440, 0.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterialText(tempobject, 0, !"{10BF42}F{7A817C}OREST", 40, !"Quartz MS", 20, 1, 0, 0, 0);
	tempobject = CreateDynamicObject(19482, 2717.254, 888.746, 10.440, 0.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterialText(tempobject, 0, !"{10BF42}F{7A817C}OREST", 40, !"Quartz MS", 20, 1, 0, 0, 0);
	tempobject = CreateDynamicObject(19482, 2717.250, 888.637, 9.180, 0.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterialText(tempobject, 0, !"{7a817c}Building company", 100, !"Ariel", 20, 1, 0, 0, 0);
	tempobject = CreateDynamicObject(19482, 2717.254, 838.295, 10.440, 0.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterialText(tempobject, 0, !"{10BF42}F{7A817C}OREST", 40, !"Quartz MS", 20, 1, 0, 0, 0);
	tempobject = CreateDynamicObject(19482, 2717.254, 821.205, 10.440, 0.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterialText(tempobject, 0, !"{10BF42}F{7A817C}OREST", 40, !"Quartz MS", 20, 1, 0, 0, 0);
	tempobject = CreateDynamicObject(19482, 2717.254, 799.225, 10.440, 0.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterialText(tempobject, 0, !"{10BF42}F{7A817C}OREST", 40, !"Quartz MS", 20, 1, 0, 0, 0);
	tempobject = CreateDynamicObject(19482, 2717.254, 909.566, 10.440, 0.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterialText(tempobject, 0, !"{10BF42}F{7A817C}OREST", 40, !"Quartz MS", 20, 1, 0, 0, 0);
	tempobject = CreateDynamicObject(19482, 2717.250, 909.427, 9.180, 0.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterialText(tempobject, 0, !"{7a817c}Building company", 100, !"Ariel", 20, 1, 0, 0, 0);
	tempobject = CreateDynamicObject(19482, 2717.250, 868.727, 9.180, 0.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterialText(tempobject, 0, !"{7a817c}Building company", 100, !"Ariel", 20, 1, 0, 0, 0);
	tempobject = CreateDynamicObject(19482, 2717.250, 838.247, 9.180, 0.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterialText(tempobject, 0, !"{7a817c}Building company", 100, !"Ariel", 20, 1, 0, 0, 0);
	tempobject = CreateDynamicObject(19482, 2717.250, 821.157, 9.180, 0.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterialText(tempobject, 0, !"{7a817c}Building company", 100, !"Ariel", 20, 1, 0, 0, 0);
	tempobject = CreateDynamicObject(19482, 2717.250, 799.156, 9.180, 0.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterialText(tempobject, 0, !"{7a817c}Building company", 100, !"Ariel", 20, 1, 0, 0, 0);
	CreateDynamicObject(1533, 2699.674, 909.015, 9.558, 0.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	
	// Около мэрии
	CreateDynamicObject(6965, 1479.5479736328, -1639.5030517578, 16.785999298096, 0, 0, 0, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(994, 1441.2099609375, -1720.6729736328, 12.796999931335, 0, 0, 0, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(994, 1441.2099609375, -1720.6728515625, 12.796999931335, 0, 0, 90, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(994, 1441.2099609375, -1713.25, 12.796999931335, 0, 0, 90, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(994, 1441.2099609375, -1705.5229492188, 12.796999931335, 0, 0, 90, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(994, 1441.2099609375, -1697.9139404297, 12.796999931335, 0, 0, 90, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(994, 1441.2099609375, -1690.3070068359, 12.796999931335, 0, 0, 90, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(994, 1448.6290283203, -1720.6729736328, 12.796999931335, 0, 0, 0, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(994, 1456.3499755859, -1720.6729736328, 12.796999931335, 0, 0, 0, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(994, 1464.0310058594, -1720.6729736328, 12.796999931335, 0, 0, 0, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(994, 1472.0739746094, -1720.6729736328, 12.796999931335, 0, 0, 0, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(994, 1480.0190429688, -1720.6729736328, 12.796999931335, 0, 0, 0, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(994, 1487.3699951172, -1720.6729736328, 12.796999931335, 0, 0, 0, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(994, 1495.1899414063, -1720.6729736328, 12.796999931335, 0, 0, 0, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(994, 1503.125, -1720.6729736328, 12.796999931335, 0, 0, 0, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(994, 1511.6560058594, -1720.6729736328, 12.796999931335, 0, 0, 0, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(994, 1517.8979492188, -1720.6700439453, 12.796999931335, 0, 0, 90, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(994, 1517.8979492188, -1713.2290039063, 12.796999931335, 0, 0, 90, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(994, 1517.8979492188, -1705.5760498047, 12.796999931335, 0, 0, 90, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(994, 1517.8979492188, -1697.9749755859, 12.796999931335, 0, 0, 90, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(994, 1517.8979492188, -1690.2740478516, 12.796999931335, 0, 0, 90, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(994, 1517.8979492188, -1682.3859863281, 12.796999931335, 0, 0, 90, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(994, 1517.8979492188, -1674.3070068359, 12.796999931335, 0, 0, 90, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(970, 1537.5670166016, -1665.9169921875, 13.097999572754, 0, 0, 270, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(970, 1537.5749511719, -1670.0460205078, 13.097999572754, 0, 0, 270, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(970, 1537.5760498047, -1674.1639404297, 13.097999572754, 0, 0, 270, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(970, 1537.5999755859, -1679.5379638672, 13.097999572754, 0, 0, 270, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(638, 1536.1259765625, -1681.9890136719, 13.244000434875, 0, 0, 270, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(638, 1536.1180419922, -1663.3900146484, 13.244000434875, 0, 0, 270, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	

	// Мэрия
	tempobject = CreateDynamicObject(19893, 226.977, 166.529, 1087.307, 0.000, 0.000, 269.996, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject,  1,  2640,  !"cj_coin_op_2",  !"CJ_POKERSCREEN",  0);
	tempobject = CreateDynamicObject(19377, 191.330, 146.417, 1097.646, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject,  0,  14815,  !"whore_main",  !"WH_tiles",  0);
	tempobject = CreateDynamicObject(19377, 195.194, 143.391, 1094.396, 0.000, 0.000, 270.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject,  0,  14815,  !"whore_main",  !"WH_tiles",  0);
	tempobject = CreateDynamicObject(19377, 199.151, 141.996, 1097.646, 0.000, 0.000, 180.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject,  0,  14815,  !"whore_main",  !"WH_tiles",  0);
	tempobject = CreateDynamicObject(19377, 194.757, 151.149, 1097.646, 0.000, 0.000, 270.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject,  0,  14815,  !"whore_main",  !"WH_tiles",  0);
	tempobject = CreateDynamicObject(19454, 199.177, 150.432, 1094.146, 90.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject,  0,  14815,  !"whore_main",  !"WH_tiles",  0);
	tempobject = CreateDynamicObject(19454, 199.164, 148.207, 1099.749, 90.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject,  0,  14815,  !"whore_main",  !"WH_tiles",  0);
	tempobject = CreateDynamicObject(19375, 193.921, 146.478, 1092.322, 0.000, 90.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject,  0,  9220,  !"sfn_apart02sfn",  !"concreteslab",  0);
	tempobject = CreateDynamicObject(19429, 193.496, 150.481, 1093.534, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject,  0,  4101,  !"stapl",  !"sl_laexpowin1",  0);
	tempobject = CreateDynamicObject(19429, 195.095, 150.481, 1093.534, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject,  0,  4101,  !"stapl",  !"sl_laexpowin1",  0);
	tempobject = CreateDynamicObject(19429, 196.470, 150.481, 1093.534, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject,  0,  4101,  !"stapl",  !"sl_laexpowin1",  0);
	tempobject = CreateDynamicObject(2420, 210.632, 183.389, 1092.396, 0.000, 0.000, 90.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject,  0,  16322,  !"a51_stores",  !"metalic128",  0);
	SetDynamicObjectMaterial(tempobject,  1,  10765,  !"airportgnd_sfse",  !"black64",  0);
	tempobject = CreateDynamicObject(2420, 210.617, 186.423, 1092.396, 0.000, 0.000, 90.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject,  0,  16322,  !"a51_stores",  !"metalic128",  0);
	SetDynamicObjectMaterial(tempobject,  1,  10765,  !"airportgnd_sfse",  !"black64",  0);
	tempobject = CreateDynamicObject(2420, 210.610, 189.223, 1092.396, 0.000, 0.000, 90.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject,  0,  16322,  !"a51_stores",  !"metalic128",  0);
	SetDynamicObjectMaterial(tempobject,  1,  10765,  !"airportgnd_sfse",  !"black64",  0);
	tempobject = CreateDynamicObject(19362, 224.104, 152.003, 1090.280, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject,  0,  18065,  !"ab_sfammumain",  !"shelf_glas",  0);
	tempobject = CreateDynamicObject(19362, 224.104, 155.216, 1086.777, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject,  0,  18065,  !"ab_sfammumain",  !"shelf_glas",  0);
	tempobject = CreateDynamicObject(19362, 224.104, 158.417, 1090.280, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject,  0,  18065,  !"ab_sfammumain",  !"shelf_glas",  0);
	tempobject = CreateDynamicObject(19362, 224.104, 180.809, 1086.777, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject,  0,  18065,  !"ab_sfammumain",  !"shelf_glas",  0);
	tempobject = CreateDynamicObject(19362, 224.104, 161.610, 1090.280, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject,  0,  18065,  !"ab_sfammumain",  !"shelf_glas",  0);
	tempobject = CreateDynamicObject(19362, 224.104, 177.606, 1086.777, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject,  0,  18065,  !"ab_sfammumain",  !"shelf_glas",  0);
	tempobject = CreateDynamicObject(19362, 224.104, 174.429, 1090.280, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject,  0,  18065,  !"ab_sfammumain",  !"shelf_glas",  0);
	tempobject = CreateDynamicObject(19362, 224.104, 171.221, 1090.280, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject,  0,  18065,  !"ab_sfammumain",  !"shelf_glas",  0);
	tempobject = CreateDynamicObject(19435, 226.273, 168.850, 1090.280, 0.000, 0.000, 47.999, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject,  0,  18065,  !"ab_sfammumain",  !"shelf_glas",  0);
	tempobject = CreateDynamicObject(19435, 224.955, 169.534, 1090.280, 0.000, 0.000, 77.997, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject,  0,  18065,  !"ab_sfammumain",  !"shelf_glas",  0);
	tempobject = CreateDynamicObject(19435, 227.137, 167.597, 1090.280, 0.000, 0.000, 21.994, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject,  0,  18065,  !"ab_sfammumain",  !"shelf_glas",  0);
	tempobject = CreateDynamicObject(19435, 227.405, 166.078, 1090.280, 0.000, 0.000, 358.489, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject,  0,  18065,  !"ab_sfammumain",  !"shelf_glas",  0);
	tempobject = CreateDynamicObject(19435, 226.929, 164.698, 1090.280, 0.000, 0.000, 324.486, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject,  0,  18065,  !"ab_sfammumain",  !"shelf_glas",  0);
	tempobject = CreateDynamicObject(19435, 225.776, 163.758, 1090.280, 0.000, 0.000, 293.735, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject,  0,  18065,  !"ab_sfammumain",  !"shelf_glas",  0);
	tempobject = CreateDynamicObject(19435, 224.800, 163.335, 1090.280, 0.000, 0.000, 291.730, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject,  0,  18065,  !"ab_sfammumain",  !"shelf_glas",  0);
	tempobject = CreateDynamicObject(19362, 224.104, 152.003, 1086.777, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject,  0,  18065,  !"ab_sfammumain",  !"shelf_glas",  0);
	tempobject = CreateDynamicObject(19362, 224.103, 155.215, 1090.280, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject,  0,  18065,  !"ab_sfammumain",  !"shelf_glas",  0);
	tempobject = CreateDynamicObject(19362, 224.103, 180.808, 1090.280, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject,  0,  18065,  !"ab_sfammumain",  !"shelf_glas",  0);
	tempobject = CreateDynamicObject(19362, 224.104, 177.639, 1090.280, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject,  0,  18065,  !"ab_sfammumain",  !"shelf_glas",  0);
	CreateDynamicObject(14602, 243.136, 166.625, 1091.947, 0.000, 0.000, 0.000, -1, -1, -1, 9999.000, 9999.000);
	CreateDynamicObject(14598, 231.293, 166.758, 1102.137, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(14596, 240.796, 151.496, 1097.277, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(14594, 213.020, 166.931, 1092.380, 0.000, 0.000, 179.994, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19377, 239.391, 154.098, 1097.637, 0.000, 0.000, 270.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1491, 199.085, 159.994, 1092.396, 0.000, 0.000, 270.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1492, 211.537, 150.414, 1092.389, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1491, 199.020, 177.968, 1092.396, 0.000, 0.000, 270.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1502, 237.462, 172.363, 1092.384, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2206, 187.498, 157.318, 1092.389, 0.000, 0.000, 270.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2161, 185.718, 161.197, 1092.897, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2167, 184.526, 152.597, 1092.389, 0.000, 0.000, 90.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2164, 187.210, 161.149, 1092.396, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1726, 198.516, 157.178, 1092.396, 0.000, 0.000, 270.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2614, 184.568, 156.150, 1094.777, 0.000, 0.000, 90.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2186, 188.195, 152.414, 1092.389, 0.000, 0.000, 180.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(14461, 191.440, 153.738, 1094.614, 0.000, 0.000, 270.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(11664, 186.748, 150.134, 1092.902, 0.000, 0.000, 270.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(18868, 187.258, 157.455, 1093.326, 0.000, 0.000, 309.995, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19823, 184.714, 151.996, 1092.389, 0.000, 0.000, 300.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19896, 186.908, 161.003, 1093.822, 0.000, 0.000, 20.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19787, 199.042, 156.412, 1095.086, 0.000, 0.000, 270.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2196, 187.772, 156.988, 1093.326, 0.000, 0.000, 219.995, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2267, 192.953, 161.192, 1094.394, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1823, 197.126, 155.705, 1092.389, 0.000, 0.000, 90.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2854, 187.626, 155.417, 1093.326, 0.000, 0.000, 280.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2855, 196.460, 156.242, 1092.885, 0.000, 0.000, 50.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1721, 228.675, 180.527, 1092.396, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1721, 199.906, 157.162, 1092.396, 0.000, 0.000, 270.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1721, 199.912, 156.485, 1092.396, 0.000, 0.000, 270.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1491, 199.167, 148.501, 1092.395, 0.000, 0.000, 270.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1715, 190.061, 158.188, 1092.389, 0.000, 0.000, 345.995, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2525, 192.725, 150.559, 1092.409, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2525, 194.251, 150.574, 1092.409, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2525, 195.776, 150.539, 1092.409, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2518, 198.529, 145.876, 1092.409, 0.000, 0.000, 270.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2518, 198.542, 145.048, 1092.409, 0.000, 0.000, 270.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(14593, 226.462, 196.570, 1088.911, 0.000, 0.000, 0.000, -1, -1, -1, 9999.000, 9999.000);
	CreateDynamicObject(1778, 199.113, 143.746, 1092.409, 0.000, 0.000, 280.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1723, 187.055, 185.882, 1092.396, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1723, 185.774, 182.559, 1092.396, 0.000, 0.000, 90.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1723, 190.542, 184.516, 1092.396, 0.000, 0.000, 270.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2311, 187.305, 183.604, 1092.396, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2162, 192.449, 187.367, 1094.201, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2164, 192.455, 187.332, 1092.396, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2167, 194.304, 187.358, 1092.396, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2200, 198.843, 180.026, 1092.396, 0.000, 0.000, 270.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2066, 195.861, 186.932, 1092.396, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1808, 198.733, 181.031, 1092.396, 0.000, 0.000, 270.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2762, 186.701, 175.222, 1092.802, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19835, 187.505, 175.531, 1093.312, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19835, 187.477, 175.095, 1093.312, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19835, 187.300, 175.367, 1093.312, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19835, 187.626, 175.365, 1093.312, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19825, 198.942, 177.184, 1095.484, 0.000, 0.000, 270.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19810, 199.710, 176.061, 1093.912, 0.000, 0.000, 270.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19807, 187.619, 157.225, 1093.401, 0.000, 0.000, 300.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19807, 223.667, 164.134, 1087.581, 0.000, 0.000, 270.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19792, 186.167, 175.591, 1093.246, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19786, 185.151, 183.457, 1095.181, 0.000, 0.000, 90.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19580, 186.804, 175.270, 1093.219, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19579, 186.401, 175.098, 1093.219, 0.000, 0.000, 330.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19578, 187.619, 183.574, 1092.931, 0.000, 0.000, 340.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19583, 185.983, 175.389, 1093.228, 0.000, 0.000, 30.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19576, 187.888, 157.074, 1093.364, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19571, 185.132, 175.026, 1092.396, 0.000, 0.000, 270.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19571, 185.182, 175.027, 1092.396, 0.000, 0.000, 270.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2120, 186.119, 176.673, 1092.909, 0.000, 0.000, 150.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2120, 188.130, 175.720, 1092.909, 0.000, 0.000, 9.996, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(955, 232.947, 180.949, 1092.822, 0.000, 0.000, 180.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1302, 193.807, 174.095, 1092.347, 0.000, 0.000, 180.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2342, 187.539, 175.231, 1093.328, 0.000, 0.000, 87.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2120, 187.479, 177.218, 1092.909, 0.000, 0.000, 59.996, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19810, 213.494, 149.914, 1093.769, 0.000, 0.000, 180.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2359, 216.475, 159.326, 1092.607, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2358, 215.533, 159.365, 1092.512, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2358, 214.832, 159.324, 1092.512, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2358, 215.132, 159.330, 1092.738, 0.000, 0.000, 14.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2370, 211.345, 158.565, 1092.396, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2370, 212.968, 158.576, 1092.396, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2370, 211.352, 156.865, 1092.396, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(348, 213.809, 158.121, 1093.269, 90.000, 0.000, 90.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(348, 213.533, 158.097, 1093.269, 90.000, 0.000, 90.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(348, 213.257, 158.123, 1093.269, 90.000, 0.000, 90.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(348, 212.983, 158.125, 1093.269, 90.000, 0.000, 90.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(348, 212.731, 158.102, 1093.269, 90.000, 0.000, 90.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(334, 213.725, 158.630, 1093.269, 90.000, 0.000, 276.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(334, 213.727, 158.830, 1093.269, 90.000, 0.000, 275.998, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(334, 213.727, 159.054, 1093.269, 90.000, 0.000, 275.998, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(334, 213.729, 159.279, 1093.269, 90.000, 0.000, 275.998, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(334, 213.731, 159.527, 1093.269, 90.000, 0.000, 275.998, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(334, 213.731, 159.751, 1093.269, 90.000, 0.000, 275.998, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(353, 213.223, 158.460, 1093.293, 90.000, 0.000, 180.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(353, 213.190, 158.785, 1093.293, 90.000, 0.000, 179.994, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(353, 213.197, 159.134, 1093.293, 90.000, 0.000, 179.994, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(353, 213.180, 159.483, 1093.293, 90.000, 0.000, 179.994, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2358, 211.072, 158.985, 1093.360, 0.000, 0.000, 89.996, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2358, 211.597, 158.990, 1093.360, 0.000, 0.000, 89.994, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2358, 211.087, 158.233, 1093.360, 0.000, 0.000, 89.994, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2358, 211.589, 158.248, 1093.360, 0.000, 0.000, 89.994, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2358, 211.257, 157.626, 1093.360, 0.000, 0.000, 359.994, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(347, 212.479, 158.986, 1093.244, 90.000, 0.000, 90.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(347, 212.468, 158.544, 1093.244, 90.000, 0.000, 90.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(347, 212.425, 158.966, 1093.244, 90.000, 0.000, 280.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(347, 212.503, 158.473, 1093.244, 90.000, 0.000, 279.997, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1271, 216.429, 150.876, 1092.746, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1271, 215.615, 150.902, 1092.746, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1271, 216.098, 150.875, 1093.447, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1650, 214.169, 159.511, 1092.703, 0.000, 0.000, 90.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1650, 214.369, 159.505, 1092.703, 0.000, 0.000, 90.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2058, 211.938, 157.110, 1092.720, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2690, 198.600, 154.649, 1092.755, 0.000, 0.000, 180.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19773, 212.218, 156.888, 1093.243, 0.000, 90.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19773, 212.201, 157.104, 1093.243, 0.000, 90.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19773, 212.179, 157.354, 1093.243, 0.000, 90.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19792, 211.214, 156.839, 1093.270, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19792, 211.214, 156.714, 1093.270, 0.000, 0.000, 40.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19792, 211.339, 156.789, 1093.270, 0.000, 0.000, 69.995, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1728, 216.432, 156.059, 1092.396, 0.000, 0.000, 270.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2208, 223.757, 189.977, 1092.396, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(14455, 191.083, 151.945, 1094.061, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2894, 224.945, 190.003, 1093.261, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2357, 189.929, 156.343, 1092.784, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1715, 191.285, 158.143, 1092.389, 0.000, 0.000, 355.994, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19166, 190.641, 161.195, 1094.473, 90.000, 90.000, 270.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1721, 199.875, 157.811, 1092.396, 0.000, 0.000, 270.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1721, 228.022, 180.537, 1092.396, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1721, 227.345, 180.520, 1092.396, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1721, 226.621, 180.473, 1092.396, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1721, 225.936, 180.529, 1092.396, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1721, 229.350, 180.542, 1092.396, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1998, 233.059, 184.479, 1092.396, 0.000, 0.000, 92.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1806, 233.121, 185.729, 1092.396, 0.000, 0.000, 100.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2200, 223.524, 180.557, 1092.389, 0.000, 0.000, 180.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2204, 221.011, 180.457, 1092.389, 0.000, 0.000, 180.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(955, 192.417, 174.303, 1092.746, 0.000, 0.000, 179.994, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2614, 200.063, 186.358, 1094.926, 0.000, 0.000, 90.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1502, 230.360, 180.438, 1092.389, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1723, 246.296, 180.662, 1092.396, 0.000, 0.000, 180.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1723, 242.634, 180.645, 1092.396, 0.000, 0.000, 179.994, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1723, 242.707, 182.776, 1092.396, 0.000, 0.000, 179.994, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1723, 246.281, 182.777, 1092.396, 0.000, 0.000, 179.994, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1723, 238.856, 182.179, 1092.396, 0.000, 0.000, 139.994, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1723, 238.757, 184.957, 1092.396, 0.000, 0.000, 139.994, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2206, 244.684, 186.791, 1092.347, 0.000, 0.000, 161.750, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2614, 245.867, 189.365, 1094.977, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2616, 238.962, 192.419, 1094.553, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2611, 242.757, 189.352, 1094.923, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1726, 226.712, 162.531, 1092.396, 0.000, 0.000, 180.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2204, 230.731, 192.046, 1086.583, 0.000, 0.000, 180.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1998, 230.158, 201.776, 1086.583, 0.000, 0.000, 90.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1998, 223.789, 193.539, 1086.583, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2204, 225.283, 191.940, 1086.583, 0.000, 0.000, 179.994, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1998, 229.700, 194.497, 1086.583, 0.000, 0.000, 270.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2204, 231.317, 204.617, 1086.583, 0.000, 0.000, 269.994, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1726, 221.479, 206.520, 1086.583, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1726, 220.615, 203.751, 1086.583, 0.000, 0.000, 90.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1502, 232.401, 189.210, 1086.583, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1723, 242.365, 173.240, 1086.581, 0.000, 0.000, 179.994, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1723, 243.343, 176.324, 1086.581, 0.000, 0.000, 269.994, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(955, 243.660, 177.861, 1086.987, 0.000, 0.000, 269.994, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2082, 240.914, 174.774, 1086.581, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2002, 243.583, 179.152, 1086.587, 0.000, 0.000, 270.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2011, 220.679, 155.285, 1086.553, 0.000, 0.000, 60.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2186, 220.667, 173.391, 1086.578, 0.000, 0.000, 90.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2002, 222.468, 151.518, 1086.579, 0.000, 0.000, 180.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2011, 243.718, 180.098, 1086.561, 0.000, 0.000, 59.996, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2190, 223.960, 162.820, 1087.505, 0.000, 0.000, 270.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2190, 223.958, 169.076, 1087.505, 0.000, 0.000, 270.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19807, 226.955, 165.727, 1087.355, 0.000, 0.000, 238.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19893, 187.333, 156.076, 1093.326, 0.000, 0.000, 239.996, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2190, 224.007, 170.373, 1087.505, 0.000, 0.000, 270.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19859, 220.154, 160.602, 1087.840, 0.000, 0.000, 270.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2164, 220.164, 165.132, 1086.579, 0.000, 0.000, 90.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2167, 220.145, 179.072, 1086.579, 0.000, 0.000, 90.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1671, 225.549, 166.455, 1087.047, 0.000, 0.000, 90.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2167, 220.112, 167.479, 1086.581, 0.000, 0.000, 90.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2164, 221.317, 182.276, 1086.578, 0.000, 0.000, 0.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2186, 220.661, 152.998, 1086.579, 0.000, 0.000, 90.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1522, 257.713, 167.429, 1086.581, 0.000, 0.000, 270.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2002, 230.746, 197.819, 1086.583, 0.000, 0.000, 270.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2011, 220.777, 202.559, 1086.557, 0.000, 0.000, 59.996, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1998, 242.845, 174.035, 1092.396, 0.000, 0.000, 270.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1998, 245.779, 172.992, 1092.396, 0.000, 0.000, 88.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1806, 242.647, 173.130, 1092.396, 0.000, 0.000, 270.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1806, 245.651, 173.742, 1092.396, 0.000, 0.000, 90.000, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2690, 213.661, 150.506, 1094.006, 0.000, 0.000, 179.994, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2690, 198.960, 175.330, 1093.786, 0.000, 0.000, 269.994, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2690, 236.092, 172.504, 1093.607, 0.000, 0.000, 179.983, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2690, 229.871, 180.479, 1094.082, 0.000, 0.000, 179.983, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2690, 220.276, 177.125, 1087.890, 0.000, 0.000, 89.983, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2690, 243.882, 173.225, 1086.939, 0.000, 0.000, 279.983, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2690, 231.108, 198.354, 1086.942, 0.000, 0.000, 179.981, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19362, 238.73399353027, 153.68099975586, 1089.8139648438, 0, 90, 270, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19362, 238.7200012207, 157.4109954834, 1089.8139648438, 0, 90, 270, -1, 2, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	
	// Склад оружия
	CreateDynamicObject(10230, -2193.071, 2459.111, 7.320, 0.000, 0.000, 135.999, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(10231, -2191.364, 2459.582, 8.777, 0.000, 0.000, 136.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3928, -2165.424, 2426.044, 7.625, 0.000, 0.000, 315.999, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(10229, -2191.936, 2459.933, 6.149, 0.000, 0.000, 136.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19545, -2195.087, 2437.531, -29.827, 270.000, 0.000, 46.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19545, -2205.489, 2426.735, -29.827, 270.000, 0.000, 45.999, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19545, -2184.292, 2427.113, -29.827, 270.000, 0.000, 225.999, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19545, -2192.267, 2419.691, -29.827, 270.000, 0.000, 45.999, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19545, -2194.970, 2416.915, -29.827, 270.000, 0.000, 45.999, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19545, -2205.314, 2416.129, -29.827, 270.000, 0.000, 135.999, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(18751, -2173.666, 2427.400, -24.635, 0.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(18751, -2180.102, 2447.334, -30.159, 0.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(18751, -2191.403, 2461.025, -37.485, 0.000, 0.000, 90.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(18751, -2167.047, 2405.687, -30.735, 0.000, 0.000, 350.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(18751, -2163.318, 2391.308, -37.884, 0.000, 0.000, 0.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(16111, -2115.232, 2499.553, -28.979, 0.000, 0.000, 30.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(16111, -2120.877, 2458.659, -38.979, 0.000, 0.000, 119.998, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(16111, -2229.177, 2422.866, -39.936, 0.000, 29.998, 39.994, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2973, -2193.799, 2432.818, 1.407, 0.000, 0.000, 45.999, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(964, -2209.173, 2422.022, 1.432, 0.000, 0.000, 315.999, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(964, -2208.253, 2421.102, 1.432, 0.000, 0.000, 315.999, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(964, -2207.350, 2420.199, 1.432, 0.000, 0.000, 315.999, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(964, -2207.822, 2420.756, 2.382, 0.000, 0.000, 335.999, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2973, -2191.937, 2434.758, 1.407, 0.000, 0.000, 45.999, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3799, -2188.385, 2425.215, 1.432, 0.000, 0.000, 316.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(8572, -2164.504, 2435.970, 6.328, 0.000, 0.000, 226.250, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(16111, -2156.718, 2480.456, -32.404, 0.000, 29.998, 359.994, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(16111, -2223.743, 2441.622, -39.936, 0.000, 29.992, 119.990, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1431, -2189.923, 2422.764, 1.980, 0.000, 0.000, 50.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2973, -2204.250, 2477.435, 6.453, 0.000, 0.000, 45.999, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2973, -2201.905, 2475.291, 6.453, 0.000, 0.000, 45.999, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19377, -2222.477, 2489.017, 12.690, 0.000, 90.000, 316.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3016, -2217.224, 2489.058, 9.274, 0.000, 0.000, 48.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3016, -2217.528, 2488.721, 9.274, 0.000, 0.000, 47.999, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3016, -2217.389, 2488.868, 9.524, 0.000, 0.000, 47.999, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3015, -2221.933, 2484.284, 9.251, 0.000, 0.000, 50.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2974, -2199.611, 2473.072, 6.453, 0.000, 0.000, 136.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2969, -2222.483, 2484.754, 9.253, 0.000, 0.000, 318.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2969, -2223.056, 2485.355, 9.253, 0.000, 0.000, 317.999, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2969, -2222.775, 2485.028, 9.453, 0.000, 0.000, 317.999, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3791, -2220.394, 2491.334, 9.592, 0.000, 0.000, 134.994, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19377, -2222.477, 2489.017, 12.840, 0.000, 90.000, 315.999, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2358, -2218.781, 2487.601, 9.243, 0.000, 0.000, 320.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2358, -2219.353, 2488.083, 9.243, 0.000, 0.000, 319.998, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2358, -2219.034, 2487.879, 9.468, 0.000, 0.000, 319.998, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2358, -2219.012, 2487.115, 9.243, 0.000, 0.000, 228.248, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2358, -2219.527, 2486.560, 9.243, 0.000, 0.000, 228.246, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2358, -2220.020, 2485.989, 9.243, 0.000, 0.000, 228.246, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2358, -2219.155, 2486.864, 9.468, 0.000, 0.000, 227.998, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2358, -2219.738, 2486.281, 9.468, 0.000, 0.000, 227.993, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2358, -2219.451, 2486.562, 9.668, 0.000, 0.000, 227.993, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2358, -2220.595, 2485.687, 9.243, 0.000, 0.000, 136.246, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2358, -2221.156, 2486.222, 9.243, 0.000, 0.000, 138.240, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2358, -2220.230, 2485.735, 9.468, 0.000, 0.000, 227.993, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2358, -2220.027, 2485.989, 9.692, 0.000, 0.000, 227.993, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2358, -2220.943, 2486.052, 9.468, 0.000, 0.000, 157.993, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2969, -2218.620, 2490.031, 9.253, 0.000, 0.000, 317.999, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2969, -2219.000, 2489.634, 9.253, 0.000, 0.000, 317.999, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2969, -2218.021, 2489.495, 9.253, 0.000, 0.000, 317.999, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2969, -2218.366, 2489.094, 9.253, 0.000, 0.000, 317.999, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2969, -2218.164, 2489.204, 9.503, 0.000, 0.000, 47.999, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2969, -2218.550, 2489.496, 9.503, 0.000, 0.000, 47.993, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2969, -2218.882, 2489.802, 9.503, 0.000, 0.000, 47.993, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3066, -2202.125, 2427.314, 2.486, 0.000, 0.000, 316.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(994, -2189.830, 2442.784, 1.432, 0.000, 0.000, 225.750, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(994, -2194.196, 2438.302, 1.432, 0.000, 0.000, 225.747, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(994, -2198.543, 2433.843, 1.432, 0.000, 0.000, 226.247, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(994, -2202.893, 2429.322, 1.432, 0.000, 0.000, 225.747, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(994, -2181.068, 2430.650, 1.432, 0.000, 0.000, 225.747, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2944, -2224.551, 2486.226, 10.621, 0.000, 0.000, 225.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1461, -2206.488, 2418.309, 2.276, 0.000, 0.000, 40.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(987, -2261.341, 2365.509, 1.292, 0.000, 0.000, 236.500, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(987, -2267.402, 2375.863, 1.292, 0.000, 0.000, 300.497, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(975, -2270.225, 2351.887, 5.445, 0.000, 0.000, 55.500, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(987, -2273.150, 2348.240, 1.292, 0.000, 0.000, 236.497, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(987, -2279.843, 2338.310, 1.292, 0.000, 0.000, 206.497, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(987, -2297.645, 2336.461, 1.292, 0.000, 0.000, 182.493, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(987, -2275.706, 2384.535, 1.292, 0.000, 0.000, 313.742, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(987, -2283.991, 2393.188, 1.292, 0.000, 0.000, 313.742, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(987, -2292.292, 2401.852, 1.292, 0.000, 0.000, 313.742, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(987, -2300.964, 2410.118, 1.292, 0.000, 0.000, 316.242, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(987, -2298.507, 2421.653, 1.292, 0.000, 0.000, 258.241, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(966, -2293.788, 2427.200, 3.914, 0.000, 0.000, 50.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(968, -2293.791, 2427.240, 4.763, 0.000, 270.000, 50.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19641, -2290.951, 2430.400, 2.476, 0.000, 0.000, 50.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19273, -2274.729, 2347.371, 5.314, 0.000, 0.000, 237.996, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19273, -2265.975, 2356.524, 5.513, 0.000, 0.000, 57.996, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19966, -2279.522, 2362.872, 4.282, 0.000, 0.000, 250.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3279, -2186.929, 2413.813, 3.986, 0.000, 0.000, 225.750, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3279, -2293.995, 2409.716, 3.914, 0.000, 0.000, 46.497, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(967, -2275.281, 2348.003, 3.819, 0.000, 0.000, 56.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(967, -2265.451, 2355.947, 3.819, 0.000, 0.000, 237.996, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	
	tempobject = CreateDynamicObject(3928, -2157.050, 2434.819, 7.625, 0.000, 0.000, 316.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 10101, !"2notherbuildsfe", !"Bow_Abpave_Gen", 0);
	SetDynamicObjectMaterial(tempobject, 1, 9514, !"711_sfw", !"ws_carpark2", 0);
	tempobject = CreateDynamicObject(19375, -2193.863, 2425.006, 1.347, 0.000, 90.000, 46.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 16640, !"a51", !"metpat64", 0);
	tempobject = CreateDynamicObject(19375, -2186.138, 2432.143, 1.347, 0.000, 90.000, 45.999, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 16640, !"a51", !"metpat64", 0);
	tempobject = CreateDynamicObject(19375, -2201.135, 2417.468, 1.347, 0.000, 90.000, 46.249, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 16640, !"a51", !"metpat64", 0);
	tempobject = CreateDynamicObject(19532, -2184.736, 2437.459, -62.500, 90.000, 0.000, 136.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 16093, !"a51_ext", !"BLOCK2", 0);
	tempobject = CreateDynamicObject(19454, -2189.410, 2435.854, 1.322, 0.000, 90.000, 316.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 16640, !"a51", !"metpat64", 0);
	tempobject = CreateDynamicObject(19454, -2198.631, 2431.312, 1.347, 0.000, 90.000, 315.999, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 16640, !"a51", !"metpat64", 0);
	tempobject = CreateDynamicObject(19454, -2191.964, 2438.237, 1.347, 0.000, 90.000, 315.999, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 16640, !"a51", !"metpat64", 0);
	tempobject = CreateDynamicObject(19454, -2196.679, 2428.300, 1.322, 0.000, 90.000, 315.999, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 16640, !"a51", !"metpat64", 0);
	tempobject = CreateDynamicObject(19454, -2203.370, 2421.373, 1.322, 0.000, 90.000, 315.999, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 16640, !"a51", !"metpat64", 0);
	tempobject = CreateDynamicObject(19454, -2205.305, 2424.373, 1.347, 0.000, 90.000, 315.999, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 16640, !"a51", !"metpat64", 0);
	tempobject = CreateDynamicObject(19378, -2222.008, 2488.768, 9.041, 0.000, 90.000, 316.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 16640, !"a51", !"pavegrey128", 0);
	tempobject = CreateDynamicObject(14416, -2224.950, 2489.574, 7.352, 0.000, 0.000, 46.000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 16640, !"a51", !"pavegrey128", 0);
	tempobject = CreateDynamicObject(19371, -2227.495, 2489.074, 10.876, 0.000, 0.000, 46.250, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 14668, !"711c", !"CJ_CHIP_M2", 0);
	tempobject = CreateDynamicObject(19371, -2224.626, 2492.111, 10.876, 0.000, 0.000, 46.246, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 14668, !"711c", !"CJ_CHIP_M2", 0);
	tempobject = CreateDynamicObject(19371, -2222.372, 2492.297, 10.876, 0.000, 0.000, 136.246, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 14668, !"711c", !"CJ_CHIP_M2", 0);
	tempobject = CreateDynamicObject(19371, -2220.115, 2492.337, 10.876, 0.000, 0.000, 46.241, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 14668, !"711c", !"CJ_CHIP_M2", 0);
	tempobject = CreateDynamicObject(19371, -2217.813, 2490.144, 10.876, 0.000, 0.000, 46.235, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 14668, !"711c", !"CJ_CHIP_M2", 0);
	tempobject = CreateDynamicObject(19371, -2217.778, 2487.939, 10.876, 0.000, 0.000, 136.235, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 14668, !"711c", !"CJ_CHIP_M2", 0);
	tempobject = CreateDynamicObject(19371, -2219.993, 2485.635, 10.876, 0.000, 0.000, 136.230, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 14668, !"711c", !"CJ_CHIP_M2", 0);
	tempobject = CreateDynamicObject(19371, -2222.202, 2483.340, 10.876, 0.000, 0.000, 136.230, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 14668, !"711c", !"CJ_CHIP_M2", 0);
	tempobject = CreateDynamicObject(19371, -2225.186, 2486.849, 10.876, 0.000, 0.000, 226.230, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 14668, !"711c", !"CJ_CHIP_M2", 0);
	tempobject = CreateDynamicObject(19371, -2222.895, 2484.645, 10.876, 0.000, 0.000, 226.230, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 14668, !"711c", !"CJ_CHIP_M2", 0);
	tempobject = CreateDynamicObject(19371, -2228.919, 2489.806, 10.876, 0.000, 0.000, 136.246, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 14668, !"711c", !"CJ_CHIP_M2", 0);
	tempobject = CreateDynamicObject(19371, -2225.742, 2493.132, 10.876, 0.000, 0.000, 136.241, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 14668, !"711c", !"CJ_CHIP_M2", 0);
	
	// Завод производства заготовок для оружия
	tempobject = CreateDynamicObject(929, 31.642, 9.871, 1001.565, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 18901, !"matclothes", !"beretblk", 0);
	tempobject = CreateDynamicObject(941, 28.892, -13.729, 1001.028, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 18646, !"matcolours", !"grey-30-percent", 0);
	SetDynamicObjectMaterial(tempobject, 1, 18646, !"matcolours", !"grey-60-percent", 0);
	tempobject = CreateDynamicObject(941, -2.607, -8.939, 1001.078, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 18646, !"matcolours", !"grey-30-percent", 0);
	SetDynamicObjectMaterial(tempobject, 1, 18646, !"matcolours", !"grey-60-percent", 0);
	tempobject = CreateDynamicObject(941, -0.280, -8.942, 1001.078, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 18646, !"matcolours", !"grey-30-percent", 0);
	SetDynamicObjectMaterial(tempobject, 1, 18646, !"matcolours", !"grey-60-percent", 0);
	tempobject = CreateDynamicObject(941, 2.068, -8.944, 1001.078, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 18646, !"matcolours", !"grey-30-percent", 0);
	SetDynamicObjectMaterial(tempobject, 1, 18646, !"matcolours", !"grey-60-percent", 0);
	tempobject = CreateDynamicObject(941, 4.418, -8.944, 1001.078, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 18646, !"matcolours", !"grey-30-percent", 0);
	SetDynamicObjectMaterial(tempobject, 1, 18646, !"matcolours", !"grey-60-percent", 0);
	tempobject = CreateDynamicObject(941, 6.769, -8.961, 1001.078, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 18646, !"matcolours", !"grey-30-percent", 0);
	SetDynamicObjectMaterial(tempobject, 1, 18646, !"matcolours", !"grey-60-percent", 0);
	tempobject = CreateDynamicObject(941, -2.607, 6.750, 1001.078, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 18646, !"matcolours", !"grey-30-percent", 0);
	SetDynamicObjectMaterial(tempobject, 1, 18646, !"matcolours", !"grey-60-percent", 0);
	tempobject = CreateDynamicObject(941, -0.250, 6.743, 1001.078, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 18646, !"matcolours", !"grey-30-percent", 0);
	SetDynamicObjectMaterial(tempobject, 1, 18646, !"matcolours", !"grey-60-percent", 0);
	tempobject = CreateDynamicObject(941, 2.101, 6.756, 1001.078, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 18646, !"matcolours", !"grey-30-percent", 0);
	SetDynamicObjectMaterial(tempobject, 1, 18646, !"matcolours", !"grey-60-percent", 0);
	tempobject = CreateDynamicObject(941, 4.464, 6.743, 1001.078, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 18646, !"matcolours", !"grey-30-percent", 0);
	SetDynamicObjectMaterial(tempobject, 1, 18646, !"matcolours", !"grey-60-percent", 0);
	tempobject = CreateDynamicObject(941, 6.839, 6.750, 1001.078, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 18646, !"matcolours", !"grey-30-percent", 0);
	SetDynamicObjectMaterial(tempobject, 1, 18646, !"matcolours", !"grey-60-percent", 0);
	tempobject = CreateDynamicObject(929, 12.472, 9.213, 1001.565, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 18901, !"matclothes", !"beretblk", 0);
	tempobject = CreateDynamicObject(929, -7.196, 10.942, 1001.565, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 18901, !"matclothes", !"beretblk", 0);
	tempobject = CreateDynamicObject(2969, 7.769, -9.229, 1001.681, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 1736, !"cj_ammo", !"CJ_SLATEDWOOD2", 0);
	tempobject = CreateDynamicObject(2969, 5.421, -9.243, 1001.681, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 1736, !"cj_ammo", !"CJ_SLATEDWOOD2", 0);
	tempobject = CreateDynamicObject(2969, 3.069, -9.255, 1001.681, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 1736, !"cj_ammo", !"CJ_SLATEDWOOD2", 0);
	tempobject = CreateDynamicObject(2969, 0.750, -9.255, 1001.681, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 1736, !"cj_ammo", !"CJ_SLATEDWOOD2", 0);
	tempobject = CreateDynamicObject(2969, -1.572, -9.277, 1001.681, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 1736, !"cj_ammo", !"CJ_SLATEDWOOD2", 0);
	tempobject = CreateDynamicObject(2969, -3.144, 7.093, 1001.681, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 1736, !"cj_ammo", !"CJ_SLATEDWOOD2", 0);
	tempobject = CreateDynamicObject(2969, -0.790, 7.070, 1001.681, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 1736, !"cj_ammo", !"CJ_SLATEDWOOD2", 0);
	tempobject = CreateDynamicObject(2969, 1.582, 7.026, 1001.681, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 1736, !"cj_ammo", !"CJ_SLATEDWOOD2", 0);
	tempobject = CreateDynamicObject(2969, 3.930, 7.085, 1001.681, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 1736, !"cj_ammo", !"CJ_SLATEDWOOD2", 0);
	tempobject = CreateDynamicObject(2969, 6.330, 7.066, 1001.681, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 1736, !"cj_ammo", !"CJ_SLATEDWOOD2", 0);
	tempobject = CreateDynamicObject(3015, -4.010, -8.852, 1000.703, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 1, 1736, !"cj_ammo", !"CJ_SLATEDWOOD2", 0);
	tempobject = CreateDynamicObject(941, 25.250, 7.801, 1001.078, 0.000, 0.000, 270.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 18646, !"matcolours", !"grey-30-percent", 0);
	SetDynamicObjectMaterial(tempobject, 1, 18646, !"matcolours", !"grey-60-percent", 0);
	tempobject = CreateDynamicObject(941, 25.253, 3.812, 1001.078, 0.000, 0.000, 90.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 18646, !"matcolours", !"grey-30-percent", 0);
	SetDynamicObjectMaterial(tempobject, 1, 18646, !"matcolours", !"grey-60-percent", 0);
	tempobject = CreateDynamicObject(929, -8.869, 10.854, 1001.565, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 18901, !"matclothes", !"beretblk", 0);
	tempobject = CreateDynamicObject(929, 11.248, 9.239, 1001.565, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 18901, !"matclothes", !"beretblk", 0);
	tempobject = CreateDynamicObject(929, 10.048, 9.286, 1001.565, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 0, 18901, !"matclothes", !"beretblk", 0);
	tempobject = CreateDynamicObject(3015, 25.315, 2.529, 1000.703, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 1, 1736, !"cj_ammo", !"CJ_SLATEDWOOD2", 0);
	tempobject = CreateDynamicObject(3015, 8.732, 6.783, 1000.679, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	SetDynamicObjectMaterial(tempobject, 1, 1736, !"cj_ammo", !"CJ_SLATEDWOOD2", 0);
	CreateDynamicObject(14412, 8.654, -1.085, 1009.947, 0.000, 0.000, 0.000, -1, -1, -1, 9999.000, 9999.000);
	CreateDynamicObject(14413, 14.196, 21.583, 1006.645, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(14413, -2.391, -23.840, 1006.645, 0.000, 0.000, 180.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(14436, 19.801, 6.938, 1010.195, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(14459, 3.880, -1.184, 1007.525, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(14409, -12.085, 5.453, 1001.544, 0.000, 0.000, 180.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(10150, 32.577, 2.815, 1002.635, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1557, -22.694, -10.607, 1004.768, 0.000, 0.000, 90.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1557, 32.498, 4.421, 1000.604, 0.000, 0.000, 270.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(10150, -14.418, -12.982, 1006.799, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1998, -16.506, 5.142, 1004.768, 0.000, 0.000, 270.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2008, -15.482, 1.161, 1004.768, 0.000, 0.000, 270.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2165, -21.940, -0.282, 1004.768, 0.000, 0.000, 90.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2174, -20.076, 12.647, 1004.768, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2181, -17.069, 12.281, 1004.768, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(10150, -22.708, -9.003, 1006.799, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1557, -14.312, -11.326, 1004.775, 0.000, 0.000, 270.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1557, 32.508, 1.396, 1000.604, 0.000, 0.000, 90.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(958, 29.423, 12.850, 1001.481, 0.000, 0.000, 180.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(936, 31.302, -13.718, 1001.078, 0.000, 0.000, 180.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(18638, 31.979, -13.904, 1001.616, 0.000, 270.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(18638, 31.979, -13.524, 1001.616, 0.000, 269.993, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(18638, 31.739, -13.578, 1001.616, 0.000, 269.993, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(18638, 31.731, -13.934, 1001.616, 0.000, 269.993, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(18638, 31.472, -13.619, 1001.616, 0.000, 269.993, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(18638, 31.451, -14.017, 1001.616, 0.000, 269.993, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(18638, 31.104, -13.946, 1001.616, 0.000, 269.993, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(18638, 31.215, -13.704, 1001.616, 0.000, 269.993, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(18638, 30.933, -13.385, 1001.616, 0.000, 269.993, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(18638, 31.305, -13.409, 1001.616, 0.000, 269.993, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(18638, 30.836, -13.779, 1001.616, 0.000, 269.993, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(18638, 30.545, -14.038, 1001.616, 0.000, 269.993, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(18638, 30.569, -13.588, 1001.616, 0.000, 269.993, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(18644, 29.927, -13.704, 1001.513, 0.000, 90.000, 270.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(18644, 30.076, -13.708, 1001.513, 0.000, 90.000, 270.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(18644, 30.000, -13.706, 1001.513, 0.000, 90.000, 270.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(18644, 30.149, -13.708, 1001.513, 0.000, 90.000, 270.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(18644, 29.825, -13.699, 1001.513, 0.000, 90.000, 270.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(18644, 29.724, -13.720, 1001.513, 0.000, 90.000, 270.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(11711, 25.860, -9.086, 1003.280, 0.000, 0.000, 90.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(11711, 32.374, 2.904, 1003.367, 0.000, 0.000, 90.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(11713, 32.374, 6.414, 1002.025, 0.000, 0.000, 180.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(18638, 29.509, -13.675, 1001.616, 0.000, 269.993, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(18638, 29.944, -13.770, 1001.616, 0.000, 269.993, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(18638, 29.263, -13.531, 1001.616, 0.000, 269.993, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(18638, 29.527, -13.258, 1001.616, 0.000, 269.993, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(5422, -10.027, -14.656, 1002.492, 0.000, 0.000, 90.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(935, -5.927, 12.136, 1001.168, 0.000, 0.000, 290.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1271, -8.494, -13.347, 1000.953, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1271, -9.970, -13.416, 1000.953, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1271, -11.003, -13.387, 1000.953, 0.000, 0.000, 20.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1431, 24.405, 12.012, 1001.151, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1431, 22.131, 11.930, 1001.151, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(935, 19.103, 11.871, 1001.168, 0.000, 0.000, 290.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(935, 20.076, 12.043, 1001.168, 0.000, 0.000, 249.994, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3014, 25.346, 10.838, 1000.840, 0.000, 0.000, 90.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3014, 25.370, 9.989, 1000.840, 0.000, 0.000, 90.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2359, 25.287, 8.081, 1001.765, 0.000, 0.000, 300.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2359, 25.121, 6.958, 1001.715, 0.000, 0.000, 249.998, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2358, 25.572, 5.814, 1000.721, 0.000, 0.000, 270.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2358, 25.172, 5.747, 1000.721, 0.000, 0.000, 270.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2358, 25.395, 5.767, 1000.945, 0.000, 0.000, 270.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2358, 25.496, 7.454, 1000.721, 0.000, 0.000, 270.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2358, 24.996, 7.460, 1000.721, 0.000, 0.000, 270.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2359, 25.156, 3.502, 1001.765, 0.000, 0.000, 249.992, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(355, 25.475, 4.425, 1001.554, 84.000, 269.997, 209.998, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(355, 25.128, 4.382, 1001.554, 83.995, 269.993, 209.998, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(348, 25.211, 8.125, 1001.705, 86.000, 90.000, 28.750, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(348, 25.020, 8.390, 1001.705, 85.995, 90.000, 208.744, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(353, 25.003, 6.935, 1001.643, 68.860, 229.845, 212.130, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(5422, 20.579, -14.659, 1002.492, 0.000, 0.000, 90.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1271, 21.877, -13.475, 1000.953, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1271, 20.815, -13.663, 1000.953, 0.000, 0.000, 50.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1271, 19.781, -13.692, 1000.953, 0.000, 0.000, 99.998, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19810, -14.206, -12.180, 1006.481, 0.000, 0.000, 270.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19815, 25.843, -0.171, 1002.229, 0.000, 0.000, 270.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19815, 25.836, -3.174, 1002.229, 0.000, 0.000, 270.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19621, 6.046, -9.345, 1001.648, 0.000, 0.000, 90.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19621, 3.595, -9.357, 1001.648, 0.000, 0.000, 90.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19621, 1.266, -9.357, 1001.648, 0.000, 0.000, 90.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19621, -1.128, -9.390, 1001.648, 0.000, 0.000, 90.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19621, -1.304, 7.228, 1001.648, 0.000, 0.000, 270.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19621, -3.456, -9.390, 1001.648, 0.000, 0.000, 90.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19621, 1.105, 7.217, 1001.648, 0.000, 0.000, 300.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19621, 3.426, 7.043, 1001.648, 0.000, 0.000, 239.998, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19621, 5.787, 7.268, 1001.648, 0.000, 0.000, 309.996, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(19621, 8.166, 7.185, 1001.648, 0.000, 0.000, 309.993, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(11713, 25.870, -6.592, 1002.335, 0.000, 0.000, 179.994, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1557, -14.312, -14.345, 1004.775, 0.000, 0.000, 90.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(1557, -22.694, -7.580, 1004.768, 0.000, 0.000, 270.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2971, 13.701, -13.163, 1000.604, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3256, -206.578, 4153.839, -896.315, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2991, 16.493, -11.953, 1001.231, 0.000, 0.000, 270.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2991, -13.130, -9.812, 1001.231, 0.000, 0.000, 270.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(2991, 16.493, -11.951, 1002.481, 0.000, 0.000, 270.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	 
	// Нефтеперерабатывающий завод
	CreateDynamicObject(3258, 177.53909, 1371.24219, 9.58590, 0.00000, 0.00000, 0.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3259, 190.64841, 1355.18750, 9.58590, 0.00000, 0.00000, 0.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3257, 191.58942, 1374.96289, 9.58590, 0.00000, 0.00000, 0.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3673, 169.75780, 1397.88281, 33.41410, 0.00000, 0.00000, 90.57080, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3674, 169.38280, 1407.11719, 35.89840, 0.00000, 0.00000, 90.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3258, 153.74220, 1444.86719, 9.58590, 0.00000, 0.00000, 0.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3673, 162.27341, 1456.12500, 33.41410, 0.00000, 0.00000, 180.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3674, 153.03909, 1455.75000, 35.89840, 0.00000, 0.00000, 180.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3675, 176.50780, 1387.85156, 27.49220, 0.00000, 0.00000, 90.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3675, 175.64841, 1394.13281, 23.78130, 0.00000, 0.00000, 90.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3675, 176.50270, 1400.63696, 22.46880, 360.00000, 270.00000, 90.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3675, 177.35941, 1390.57031, 19.14840, 90.00000, 0.00000, 0.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3675, 175.64841, 1392.15625, 16.29690, 0.00000, 0.00000, 90.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3675, 175.64841, 1394.13281, 10.11720, 180.00000, 0.00000, 270.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3675, 176.50780, 1404.23438, 18.29690, 360.00000, 90.00000, 90.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3675, 177.35941, 1409.00000, 19.75780, 0.00000, 0.00000, 180.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3675, 173.95309, 1409.91406, 16.29690, 0.00000, 0.00000, 180.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3675, 174.64059, 1409.85156, 11.40630, 90.00000, 90.00000, 0.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3258, 191.17970, 1390.29688, 9.58590, 0.00000, 0.00000, 0.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3259, 190.83759, 1404.25208, 9.58590, 0.00000, 0.00000, 0.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3257, 191.66158, 1421.04614, 9.58590, 0.00000, 0.00000, 180.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3258, 182.07809, 1426.03125, 9.58590, 0.00000, 0.00000, 0.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3259, 184.76053, 1445.69275, 9.58590, 0.00000, 0.00000, 1.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3258, 192.50780, 1444.69531, 9.58590, 0.00000, 0.00000, 0.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3256, 198.25780, 1467.53906, 9.58590, 0.00000, 0.00000, 0.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3673, 217.92970, 1461.85938, 33.41410, 0.00000, 0.00000, 90.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3674, 217.55470, 1471.09375, 35.89840, 0.00000, 0.00000, 90.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3259, 232.50755, 1465.18311, 9.58590, 0.00000, 0.00000, 0.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3255, 216.56250, 1435.19531, 9.68750, 0.00000, 0.00000, 0.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3255, 216.56250, 1410.53906, 9.68750, 0.00000, 0.00000, 0.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3255, 216.56250, 1385.89063, 9.68750, 0.00000, 0.00000, 0.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3255, 216.56250, 1361.24219, 9.68750, 0.00000, 0.00000, 0.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3675, 224.67970, 1451.82813, 27.49220, 0.00000, 0.00000, 90.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3675, 225.53130, 1454.54688, 19.14840, 90.00000, 0.00000, 0.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3675, 223.82030, 1456.13281, 16.29690, 0.00000, 0.00000, 90.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3675, 223.82030, 1458.10938, 23.78130, 0.00000, 0.00000, 90.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3675, 223.82030, 1458.10938, 10.11720, 180.00000, 0.00000, 270.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3675, 224.67970, 1464.63281, 22.46880, 360.00000, 270.00000, 90.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3675, 225.53130, 1472.97656, 19.75780, 0.00000, 0.00000, 180.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3675, 224.67970, 1468.21094, 18.29690, 360.00000, 90.00000, 90.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3675, 222.81250, 1473.82813, 11.40630, 90.00000, 0.00000, 90.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3675, 222.12500, 1473.89063, 16.29690, 0.00000, 0.00000, 180.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3675, 159.50000, 1462.87500, 22.46880, 360.00000, 270.00000, 180.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3675, 151.15630, 1463.72656, 19.75780, 0.00000, 0.00000, 270.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3675, 150.24220, 1460.32031, 16.29690, 0.00000, 0.00000, 270.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3675, 150.30470, 1461.00781, 11.40633, 90.00000, 180.00000, 0.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3675, 155.92191, 1462.87500, 18.29690, 360.00000, 90.00000, 180.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3675, 166.02341, 1462.01563, 23.78130, 0.00000, 0.00000, 180.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3675, 182.30470, 1462.87500, 27.49220, 0.00000, 0.00000, 180.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3675, 168.00000, 1462.01563, 16.29690, 0.00000, 0.00000, 180.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3675, 169.58591, 1463.72656, 19.14840, 90.00000, 90.00000, 0.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(3675, 166.02341, 1462.01563, 10.11720, 0.00000, 180.00000, 0.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	CreateDynamicObject(16086, 202.28909, 1434.48438, 13.50000, 0.00000, 0.00000, 0.00000, 0, 0, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
	
	for(new i = 1; i < MAX_TRAYS_EAT; i ++)
	{
		eat[i][eat_id] = i;
		eat[i][eat_status] = 0;
		eat[i][eat_x] = 0.00;
		eat[i][eat_y] = 0.00;
		eat[i][eat_z] = 0.00;
		eat[i][eat_angle] = 0.00;
		eat[i][eat_interior] = 0;
		eat[i][eat_virtualworld] = 0;
		eat[i][eat_time_drop] = 0;
	}
	return 1;
}

public OnGameModeExit()
{
	TextDrawDestroy(server_logotype);
	for(new i; i < sizeof(server_skin_show); i ++)  TextDrawDestroy(server_skin_show[i]);
	SavePlant();
	server_approachability = false;
	mysql_close(server_database);
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	//TogglePlayerSpectating(playerid, true);
	SetTimerEx(!"@RequestClass", 10, false, !"d", playerid);
	return false;
}

public OnPlayerConnect(playerid)
{
	ResetPlayerInfo(playerid);
	SetPVarInt(playerid, !"fly_camera", 1);
	SetSpawnInfo(playerid,	0,	0,	1481.7009,	-1415.2671,	11.8828,	0.00,	0,	0,	0,	0,	0, 	0);
	SpawnPlayer(playerid);
	if(server_approachability == true)
	{
		// ЖДЛС, Автовокзал
		RemoveBuildingForPlayer(playerid,	5024,	1748.8438,	-1883.0313,		14.1875,	0.25);
		RemoveBuildingForPlayer(playerid,	5083,	1748.8400,	-1883.0300,		14.1875,	0.25); 
		RemoveBuildingForPlayer(playerid,	5084,	1898.4000,	-1913.4100,		20.8203, 	0.25); 
		
		// Удаление граффити по всей карте
		RemoveBuildingForPlayer(playerid,	1490,	0.00, 	0.00, 	0.00, 	16000); 
		RemoveBuildingForPlayer(playerid,	1524,	0.00, 	0.00, 	0.00, 	16000); 
		RemoveBuildingForPlayer(playerid,	1525,	0.00, 	0.00, 	0.00, 	16000); 
		RemoveBuildingForPlayer(playerid,	1527,	0.00, 	0.00,	0.00, 	16000);
		RemoveBuildingForPlayer(playerid,	1528,	0.00, 	0.00, 	0.00, 	16000); 
		RemoveBuildingForPlayer(playerid,	1529,	0.00, 	0.00, 	0.00, 	16000);
		RemoveBuildingForPlayer(playerid,	1530,	0.00, 	0.00, 	0.00, 	16000); 
		RemoveBuildingForPlayer(playerid,	1531,	0.00, 	0.00, 	0.00, 	16000);
		RemoveBuildingForPlayer(playerid,	4981,	0.00, 	0.00, 	0.00, 	16000); 
		
		// Стройка
		RemoveBuildingForPlayer(playerid, 1358, 2671.601, 867.851, 11.125, 0.250);
		RemoveBuildingForPlayer(playerid, 1365, 2677.265, 861.687, 11.046, 0.250);
		RemoveBuildingForPlayer(playerid, 1685, 0.00, 0.00, 0.00, 16000);
		RemoveBuildingForPlayer(playerid, 3504, 0.00, 0.00, 0.00, 16000);
		
		// Склад оружия
		RemoveBuildingForPlayer(playerid, 5024, 1748.8438, -1883.0313, 14.1875, 0.25);
		RemoveBuildingForPlayer(playerid, 9381, -2235.5547, 2361.7734, 15.8047, 0.25);
		RemoveBuildingForPlayer(playerid, 9384, -2187.1172, 2414.3203, 6.5313, 0.25);
		RemoveBuildingForPlayer(playerid, 1635, -2226.0625, 2360.8281, 6.3984, 0.25);
		RemoveBuildingForPlayer(playerid, 1440, -2244.2344, 2361.2031, 4.4453, 0.25);
		RemoveBuildingForPlayer(playerid, 1431, -2245.7109, 2363.3047, 4.5000, 0.25);
		RemoveBuildingForPlayer(playerid, 9245, -2235.5547, 2361.7734, 15.8047, 0.25);
		RemoveBuildingForPlayer(playerid, 1227, -2253.5391, 2372.5469, 4.7578, 0.25);
		RemoveBuildingForPlayer(playerid, 1264, -2254.0859, 2371.0313, 4.3828, 0.25);
		RemoveBuildingForPlayer(playerid, 1264, 0.00, 0.00, 0.00, 16000);
		RemoveBuildingForPlayer(playerid, 9362, -2188.7109, 2413.3516, 4.9063, 0.25);
		RemoveBuildingForPlayer(playerid, 9361, -2187.1172, 2414.3203, 6.5313, 0.25);
		RemoveBuildingForPlayer(playerid, 9352, -2421.0469, 2343.6953, 19.7891, 0.25);
		
		// Нефтеперерабатывающий завод
		RemoveBuildingForPlayer(playerid, 3682, 247.9297, 1461.8594, 33.4141, 0.25);
		RemoveBuildingForPlayer(playerid, 3682, 192.2734, 1456.1250, 33.4141, 0.25);
		RemoveBuildingForPlayer(playerid, 3682, 199.7578, 1397.8828, 33.4141, 0.25);
		RemoveBuildingForPlayer(playerid, 3683, 166.7891, 1356.9922, 17.0938, 0.25);
		RemoveBuildingForPlayer(playerid, 3683, 166.7891, 1392.1563, 17.0938, 0.25);
		RemoveBuildingForPlayer(playerid, 3683, 166.7891, 1426.9141, 17.0938, 0.25);
		RemoveBuildingForPlayer(playerid, 3288, 221.5703, 1374.9688, 9.5859, 0.25);
		RemoveBuildingForPlayer(playerid, 3289, 212.0781, 1426.0313, 9.5859, 0.25);
		RemoveBuildingForPlayer(playerid, 3290, 218.2578, 1467.5391, 9.5859, 0.25);
		RemoveBuildingForPlayer(playerid, 3291, 246.5625, 1435.1953, 9.6875, 0.25);
		RemoveBuildingForPlayer(playerid, 3291, 246.5625, 1410.5391, 9.6875, 0.25);
		RemoveBuildingForPlayer(playerid, 3291, 246.5625, 1385.8906, 9.6875, 0.25);
		RemoveBuildingForPlayer(playerid, 3291, 246.5625, 1361.2422, 9.6875, 0.25);
		RemoveBuildingForPlayer(playerid, 3290, 190.9141, 1371.7734, 9.5859, 0.25);
		RemoveBuildingForPlayer(playerid, 3289, 183.7422, 1444.8672, 9.5859, 0.25);
		RemoveBuildingForPlayer(playerid, 3289, 222.5078, 1444.6953, 9.5859, 0.25);
		RemoveBuildingForPlayer(playerid, 3289, 221.1797, 1390.2969, 9.5859, 0.25);
		RemoveBuildingForPlayer(playerid, 3288, 223.1797, 1421.1875, 9.5859, 0.25);
		RemoveBuildingForPlayer(playerid, 3289, 207.5391, 1371.2422, 9.5859, 0.25);
		RemoveBuildingForPlayer(playerid, 3424, 220.6484, 1355.1875, 9.5859, 0.25);
		RemoveBuildingForPlayer(playerid, 3424, 221.7031, 1404.5078, 9.5859, 0.25);
		RemoveBuildingForPlayer(playerid, 3424, 210.4141, 1444.8438, 9.5859, 0.25);
		RemoveBuildingForPlayer(playerid, 3424, 262.5078, 1465.2031, 9.5859, 0.25);
		RemoveBuildingForPlayer(playerid, 3259, 220.6484, 1355.1875, 9.5859, 0.25);
		RemoveBuildingForPlayer(playerid, 3636, 166.7891, 1356.9922, 17.0938, 0.25);
		RemoveBuildingForPlayer(playerid, 3256, 190.9141, 1371.7734, 9.5859, 0.25);
		RemoveBuildingForPlayer(playerid, 3636, 166.7891, 1392.1563, 17.0938, 0.25);
		RemoveBuildingForPlayer(playerid, 3258, 207.5391, 1371.2422, 9.5859, 0.25);
		RemoveBuildingForPlayer(playerid, 3673, 199.7578, 1397.8828, 33.4141, 0.25);
		RemoveBuildingForPlayer(playerid, 3257, 221.5703, 1374.9688, 9.5859, 0.25);
		RemoveBuildingForPlayer(playerid, 3258, 221.1797, 1390.2969, 9.5859, 0.25);
		RemoveBuildingForPlayer(playerid, 3674, 199.3828, 1407.1172, 35.8984, 0.25);
		RemoveBuildingForPlayer(playerid, 3259, 221.7031, 1404.5078, 9.5859, 0.25);
		RemoveBuildingForPlayer(playerid, 3257, 223.1797, 1421.1875, 9.5859, 0.25);
		RemoveBuildingForPlayer(playerid, 3258, 212.0781, 1426.0313, 9.5859, 0.25);
		RemoveBuildingForPlayer(playerid, 3636, 166.7891, 1426.9141, 17.0938, 0.25);
		RemoveBuildingForPlayer(playerid, 3255, 246.5625, 1361.2422, 9.6875, 0.25);
		RemoveBuildingForPlayer(playerid, 3255, 246.5625, 1385.8906, 9.6875, 0.25);
		RemoveBuildingForPlayer(playerid, 3255, 246.5625, 1410.5391, 9.6875, 0.25);
		RemoveBuildingForPlayer(playerid, 3258, 183.7422, 1444.8672, 9.5859, 0.25);
		RemoveBuildingForPlayer(playerid, 3259, 210.4141, 1444.8438, 9.5859, 0.25);
		RemoveBuildingForPlayer(playerid, 3258, 222.5078, 1444.6953, 9.5859, 0.25);
		RemoveBuildingForPlayer(playerid, 3673, 192.2734, 1456.1250, 33.4141, 0.25);
		RemoveBuildingForPlayer(playerid, 3674, 183.0391, 1455.7500, 35.8984, 0.25);
		RemoveBuildingForPlayer(playerid, 3675, 0.00, 0.00, 0.00, 16000);
		RemoveBuildingForPlayer(playerid, 3256, 218.2578, 1467.5391, 9.5859, 0.25);
		RemoveBuildingForPlayer(playerid, 3255, 246.5625, 1435.1953, 9.6875, 0.25);
		RemoveBuildingForPlayer(playerid, 3259, 262.5078, 1465.2031, 9.5859, 0.25);
		RemoveBuildingForPlayer(playerid, 3673, 247.9297, 1461.8594, 33.4141, 0.25);
		RemoveBuildingForPlayer(playerid, 3674, 247.5547, 1471.0938, 35.8984, 0.25);
		RemoveBuildingForPlayer(playerid, 16086, 232.2891, 1434.4844, 13.5000, 0.25);
		
		// Завод
		RemoveBuildingForPlayer(playerid, 3377, -149.9141, -324.3438, 1.5781, 0.25);
		RemoveBuildingForPlayer(playerid, 12932, -117.9609, -337.4531, 3.6172, 0.25);
		RemoveBuildingForPlayer(playerid, 3378, -149.9141, -324.3438, 1.5781, 0.25);
		RemoveBuildingForPlayer(playerid, 14671, -3.8281, -26.4688, 1004.5313, 0.25);
		
		// Чекпоинты с помощью (ЖДЛС, Автовокзал)
		player_help_checkpoint[playerid][0] = CreateDynamicCP(1139.4917,	-1761.4667,		13.5951, 	1.50, 	0,	0,	playerid,	30.00);
		player_help_checkpoint[playerid][1] = CreateDynamicCP(1762.0842,	-1885.9574, 	13.5551, 	1.50, 	0,	0,	playerid,	30.00);

		player_timer[playerid] = SetTimerEx(!"@PlayerTime", 1000, false, !"i", playerid);
		GetPlayerName(playerid, PlayerInfo[playerid][Name], MAX_PLAYER_NAME);
		GetPlayerIp(playerid, PlayerInfo[playerid][IP], 16);
		TextDrawShowForPlayer(playerid, server_logotype);
		for(new r; r < sizeof(ReconnectInfo); r ++)
		{
			if(!strcmp(ReconnectInfo[r][IP], PlayerInfo[playerid][IP], false))
			{
				if(ReconnectInfo[r][TimeQuit] > gettime())
				{
					ReconnectInfo[r][TimeQuit] = gettime() + 7;
					SendClientMessage(playerid, WHITE, !"Минимально допустимое время перед следующим входом в игру составляет - {76FF03}7{ffffff} секунд");
					SendClientMessage(playerid, WHITE, !"Используйте {76FF03}/q(quit){ffffff} для выхода из игры");
					KickPlayer(playerid);
				}
				else
				{	
					strmid(ReconnectInfo[r][IP], !"", 0, 0, MAX_PLAYER_NAME);
					ReconnectInfo[r][TimeQuit] = 0;
				}
				break;
			}
		}
		static const sql_string[] = "SELECT `Password` FROM `Accounts` WHERE `Name` = '%s'";
		new string[sizeof(sql_string) - 2 + MAX_PLAYER_NAME + 1];
		format(string, sizeof(string), sql_string, PlayerInfo[playerid][Name]);
		mysql_function_query(server_database, string, true, !"IsPlayerAccounts", "i", playerid);
	}
	else
	{
		ShowPlayerDialog(playerid, 999, DIALOG_STYLE_MSGBOX, !"{1976D2}Технические работы",
			!"{ffffff}Внимание, произошла непредвиденная ошибка.В данный момент\n\
			осуществить вход на сервер невозможно.Повторите попытку позже.\n\n\
			Если это окошко не исчезнет через пару минут - сообщите администрации.", !"Закрыть", !"");
		KickPlayer(playerid);
	}
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	KillTimer(player_timer[playerid]);
	player_logged[playerid] = false;
	//strmid(ReconnectInfo[playerid][Name], PlayerInfo[playerid][Name], 0, strlen(PlayerInfo[playerid][Name]), MAX_PLAYER_NAME);
	//strmid(ReconnectInfo[playerid][IP], PlayerInfo[playerid][IP], 0, strlen(PlayerInfo[playerid][IP]), 16);
	//ReconnectInfo[playerid][TimeQuit] = gettime() + 7;
	if(GetPVarInt(playerid, !"skin_select") == 1)
	{
		DestroyActor(player_actor_show[playerid]); 
		for(new i; i < sizeof(server_skin_show); i ++)  TextDrawHideForPlayer(playerid, server_skin_show[i]);
	}
	if(eat_player[playerid] != 0)
		DestroyEat(eat_player[playerid]);
	SavePlayer(playerid);
	return 1;
}

stock DestroyEat(id)
{
	DestroyDynamicObject(eat[id][eat_id]);
	DestroyDynamic3DTextLabel(eat[id][eat_text]);
	eat[id][eat_x] = 0.00;
	eat[id][eat_y] = 0.00;
	eat[id][eat_z] = 0.00;
	eat[id][eat_angle] = 0.00;
	eat[id][eat_virtualworld] = 0;
	eat[id][eat_interior] = 0;
	eat[id][eat_status] = 0;
}

public OnPlayerSpawn(playerid)
{
			
	if(GetPVarInt(playerid, !"fly_camera") == 1)
	{
		TogglePlayerSpectating(playerid, true);
		TogglePlayerControllable(playerid, false);
		SetPlayerVirtualWorld(playerid, playerid + 1);
		SetPlayerInterior(playerid, 0);
		InterpolateCameraPos(playerid, 1454.357177, -1452.175292, 13.653491, 1454.015136, -1207.998413, 33.221370, 50000);
		InterpolateCameraLookAt(playerid, 1454.491455, -1447.188110, 13.984818, 1453.936767, -1203.017211, 33.647216, 30000);
		DeletePVar(playerid, !"fly_camera");
		return 1;
	}
	if(GetPVarInt(playerid, !"skin_select") == 1)
	{
		// Выбор скина при регистрации
		new tempobject;
		tempobject = CreateDynamicObject(19381,	675.955, 22.946, 1041.805, 0.000, 90.000, 0.0000, playerid, playerid, playerid, STREAMER_SMALL_OBJECT_DISTANCE,	STREAMER_OBJECT_DRAW_DISTANCE);
		SetDynamicObjectMaterial(tempobject, 0, 14534, !"ab_wooziea", !"walp72S", 0);
		tempobject = CreateDynamicObject(19448, 681.034, 22.938, 1043.640, 0.000, 0.0000, 0.0000, playerid, playerid, playerid, STREAMER_SMALL_OBJECT_DISTANCE,	STREAMER_OBJECT_DRAW_DISTANCE);
		SetDynamicObjectMaterial(tempobject, 0, 14789, !"ab_sfgymmain", !"ab_wood02", 0);
		tempobject = CreateDynamicObject(19448, 676.375, 27.541, 1043.640, 0.000, 0.0000, 90.000, playerid, playerid, playerid, STREAMER_SMALL_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
		SetDynamicObjectMaterial(tempobject, 0,	14789, !"ab_sfgymmain", !"ab_wood02", 0);
		CreateDynamicObject(1726, 676.518, 26.795, 1041.890, 0.000, 0.000, 0.00000,	playerid, playerid,	playerid, STREAMER_SMALL_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
		CreateDynamicObject(2390, 679.080, 27.246, 1043.730, 0.000,	0.000, 0.00000,	playerid, playerid,	playerid, STREAMER_SMALL_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
		CreateDynamicObject(2396, 680.734, 25.659, 1043.755, 0.000,	0.000, 270.000,	playerid, playerid,	playerid, STREAMER_SMALL_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
		CreateDynamicObject(2399, 680.796, 25.040, 1043.739, 0.000,	0.000, 270.000,	playerid, playerid,	playerid, STREAMER_SMALL_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
		CreateDynamicObject(2372, 680.664, 22.816, 1041.890, 0.000,	0.000, 0.00000,	playerid, playerid,	playerid, STREAMER_SMALL_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
		CreateDynamicObject(2381, 680.463, 23.422, 1042.553, 0.000,	0.000, 270.000,	playerid, playerid,	playerid, STREAMER_SMALL_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
		CreateDynamicObject(2654, 680.289, 26.804, 1042.109, 0.000,	0.000, 220.000,	playerid, playerid,	playerid, STREAMER_SMALL_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
		CreateDynamicObject(2694, 680.505, 25.021, 1042.000, 0.000,	0.000, 0.00000,	playerid, playerid,	playerid, STREAMER_SMALL_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
		CreateDynamicObject(2694, 680.609, 25.718, 1042.000, 0.000,	0.000, 212.000,	playerid, playerid,	playerid, STREAMER_SMALL_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
		CreateDynamicObject(19377, 676.015, 23.284, 1045.267, 0.000, 90.00, 0.00000, playerid, playerid, playerid, STREAMER_SMALL_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
		
		SetPlayerVirtualWorld(playerid, playerid);
		SetPlayerInterior(playerid, playerid);
		InterpolateCameraPos(playerid, 676.287292, 22.710088, 1042.948242, 676.287292, 22.710088, 1042.948242, 1000);
		InterpolateCameraLookAt(playerid, 679.895019, 26.171922, 1042.944335, 679.895019, 26.171922, 1042.944335, 1000);		
		SetPVarInt(playerid, !"click_skin", 1);
		DestroyActor(player_actor_show[playerid]); 
		player_actor_skin_id[playerid] = 78;
		player_actor_show[playerid] = CreateActor(player_actor_skin_id[playerid], 678.9570, 25.3431, 1042.8910, 135.00);
		SetActorVirtualWorld(player_actor_show[playerid], playerid);
		for(new i; i < sizeof(server_skin_show); i ++)  TextDrawShowForPlayer(playerid, server_skin_show[i]);
		SelectTextDraw(playerid, 0x00d371FF);
		SendClientMessage(playerid, WHITE, !"Для изменения внешности персонажа используйте кнопки {00d371}\"NEXT\"{ffffff} (вперед), {00d371}\"PREVIOUS\"{ffffff} (назад)");
  		SendClientMessage(playerid, WHITE, !"Пол персонажа установится автоматически, в зависимости от выбраной внешности");
  		SendClientMessage(playerid, WHITE, !"Для сохранения настроек и начала игры,  используйте кнопку {004ee6}\"PLAY\"{ffffff}");
		return 1;
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	SpawnPlayer(playerid);
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	for(new i = 0; i < sizeof(TankInfo); i ++)
	{
		if(vehicleid == TankInfo[i][tank_id])
		{
			TankInfo[i][tank_fuel] = 0;
			switch(vehicleid)
			{
				case 4: UpdateDynamic3DTextLabelText(text_car_plant[0], WHITE, !"Цистерна\nЗалито {33FF00}0{ffffff}/{33FF00}5000{ffffff} литров топлива");
				case 5: UpdateDynamic3DTextLabelText(text_car_plant[1], WHITE, !"Цистерна\nЗалито {33FF00}0{ffffff}/{33FF00}5000{ffffff} литров топлива");
				case 6: UpdateDynamic3DTextLabelText(text_car_plant[2], WHITE, !"Цистерна\nЗалито {33FF00}0{ffffff}/{33FF00}5000{ffffff} литров топлива");
			}
		}
	}
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	new vehicle = GetPlayerVehicleID(playerid);
	if(newstate == PLAYER_STATE_DRIVER)
	{
		if(vehicle >= TankInfo[0][tank_id] || vehicle <= TankInfo[2][tank_id])
		{
			if(!job_plant[playerid])
			{
				SendClientMessage(playerid, GRAY, !"Транспорт доступен только для работников завода");
				RemovePlayerFromVehicle(playerid);
			}
			else
			{
				SendClientMessage(playerid, WHITE, !"Для доставки топлива в хранилище завода, отправляйтесь на {33FF00}нефтеперерабатывающий завод");
				SendClientMessage(playerid, WHITE, !"Он отмечен у вас на миникарте {d50000}красным флажком");
				SetPlayerMapIcon(playerid, 0, 288.4480, 1411.5031, 15.6578, 19, 0, MAPICON_GLOBAL);
			}
		}
	}
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	switch(SetTypeCheckpoint[playerid])
	{
		case JOB_BUILDING_PUT:
		{
			if(job_building[playerid] == 0)
				return false;
			job_building_bag[playerid] = 0;
			DisablePlayerCheckpoint(playerid);
			ClearPlayerAnim(playerid);
			ApplyAnimation(playerid, !"CARRY", !"putdwn", 4.1, 0, 0, 0, 0, 0, 0);
			RemovePlayerAttachedObject(playerid, 1);
			RandomCheckpointBuilding(playerid);
			static const info[] = "Вы отнесли мешок с цементом.К зарплате добавлено {33FF00}%i${ffffff}.Текущий баланс: {33FF00}%i$";
			array:string[sizeof(info) + ((- 2 + 9) * 2) + 1];
			new salary = 50 + random(16);
			job_building_money[playerid] = job_building_money[playerid] + salary;
			format(string, sizeof(string), info, salary, job_building_money[playerid]);
			SendClientMessage(playerid, WHITE, string);
			if(GetPVarInt(playerid, !"building") == 0)
			{
				SendClientMessage(playerid, WHITE, !"Возвращайтесь назад и возьмите еще один мешок");
				SetPVarInt(playerid, !"building", 1);
			}
			
		}
		case JOB_BUILDING_TAKE:
		{
			if(job_building[playerid] == 0)
				return false;
			job_building_bag[playerid] = 1;
			DisablePlayerCheckpoint(playerid);
			ClearPlayerAnim(playerid);
			ApplyAnimation(playerid, !"CARRY", !"liftup", 4.1, 0, 0, 0, 0, 0, 0);
			SetTimerEx(!"GiveBag", 1200, false, !"i", playerid);
			RandomCheckpointBuilding_2(playerid);
			if(GetPVarInt(playerid, !"building") == 0)
				SendClientMessage(playerid, GRAY, !"Для продолжения: cледуйте к {d50000}красному маркеру");
			if(GetPVarInt(playerid, !"building") == 1)
			{
				SendClientMessage(playerid, GRAY, !"Продолжайте работать.Для завершения рабочего дня и получения заработанной харплаты");
				SendClientMessage(playerid, GRAY, !"Проследуйте к иконке синей рубашки.Она дополнительно помечена на миникарте значком трактора");
				SetPVarInt(playerid, !"building", 2);
			}
		}
		case JOB_PLANT_TAKE:
		{
			if(job_plant[playerid] == 0)
				return false;
			DisablePlayerCheckpoint(playerid);
			ClearPlayerAnim(playerid);
			ApplyAnimation(playerid, !"CARRY", !"crry_prtial", 4.0, 1, 0, 0, 1, 1, 1);
			SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
			SetPlayerAttachedObject(playerid, 2, 355, 14, 0.401943, 0.011442, 0.010348, 106.050292, 330.509094, 3.293162, 1.000000, 1.000000, 1.000000);
			if(GetPVarInt(playerid, !"plant") == 0)
			{
				SendClientMessage(playerid, GRAY, !"Для продолжения: cледуйте к {d50000}красному маркеру");
			}
		}
	}
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(IsPlayerInRangeOfPoint(playerid, 100, 7.7525, -1.1693, 1001.6033))
	{
		if(newkeys == KEY_FIRE)
		{
			if(IsPlayerAttachedObjectSlotUsed(playerid, 4))
			{
				job_plant_metal[playerid] = false;
				RemovePlayerAttachedObject(playerid, 2);
				RemovePlayerAttachedObject(playerid, 3);
				RemovePlayerAttachedObject(playerid, 4);
				SendClientMessage(playerid, WHITE, "Вы уронили заготовку.С вашей зарплаты была {33FF00}удержана{ffffff} определенная сумма");
				SendClientMessage(playerid, WHITE, "Возьмите вновь {33FF00}металические заготовки{ffffff} и продолжайте работу");
				ClearPlayerAnim(playerid);
				DisablePlayerCheckpoint(playerid);
				RandomPickuptPlant(playerid);
				SetTypeCheckpoint[playerid] = NONE;
			}
		}
	}
	if(newkeys == KEY_FIRE)
		if(eat_player[playerid] >= 1)
			DropEat(playerid);
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnPlayerTakeDamage(playerid, issuerid, Float: amount, weaponid, bodypart)
{
    return 1;
}

public OnPlayerGiveDamage(playerid, damagedid, Float: amount, weaponid, bodypart)
{
    return 1;
}


public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
    if(clickedid == Text:INVALID_TEXT_DRAW)
    {
        if(GetPVarInt(playerid, !"skin_select") == 1)
        {
            ShowDialogSkin(playerid);
		}
	}
	if(clickedid == server_skin_show[2])
	{
		switch(GetPVarInt(playerid, !"click_skin"))
		{
			case 1: SetPVarInt(playerid, !"click_skin", 2), player_actor_skin_id[playerid] = 79, TextDrawSetSelectable(server_skin_show[3], true), TextDrawColor(server_skin_show[3], -1), TextDrawShowForPlayer(playerid, server_skin_show[3]);
			case 2: SetPVarInt(playerid, !"click_skin", 3), player_actor_skin_id[playerid] = 95;
			case 3: SetPVarInt(playerid, !"click_skin", 4), player_actor_skin_id[playerid] = 132;
			case 4: SetPVarInt(playerid, !"click_skin", 5), player_actor_skin_id[playerid] = 134;
			case 5: SetPVarInt(playerid, !"click_skin", 6), player_actor_skin_id[playerid] = 135;
			case 6: SetPVarInt(playerid, !"click_skin", 7), player_actor_skin_id[playerid] = 136;
			case 7: SetPVarInt(playerid, !"click_skin", 8), player_actor_skin_id[playerid] = 137;
			case 8: SetPVarInt(playerid, !"click_skin", 9), player_actor_skin_id[playerid] = 159;
			case 9: SetPVarInt(playerid, !"click_skin", 10), player_actor_skin_id[playerid] = 160;
			case 10: SetPVarInt(playerid, !"click_skin", 11), player_actor_skin_id[playerid] = 200;
			case 11: SetPVarInt(playerid, !"click_skin", 12), player_actor_skin_id[playerid] = 230;
			case 12: SetPVarInt(playerid, !"click_skin", 13), player_actor_skin_id[playerid] = 31;
			case 13: SetPVarInt(playerid, !"click_skin", 14), player_actor_skin_id[playerid] = 38;
			case 14: SetPVarInt(playerid, !"click_skin", 15), player_actor_skin_id[playerid] = 54;
			case 15: SetPVarInt(playerid, !"click_skin", 16), player_actor_skin_id[playerid] = 64;
			case 16: SetPVarInt(playerid, !"click_skin", 17), player_actor_skin_id[playerid] = 65;
			case 17: SetPVarInt(playerid, !"click_skin", 18), player_actor_skin_id[playerid] = 75;
			case 18: SetPVarInt(playerid, !"click_skin", 19), player_actor_skin_id[playerid] = 90, TextDrawSetSelectable(server_skin_show[2], false), TextDrawColor(server_skin_show[2], 0x757575FF), TextDrawShowForPlayer(playerid, server_skin_show[2]);
		}
		DestroyActor(player_actor_show[playerid]); 
		player_actor_show[playerid] = CreateActor(player_actor_skin_id[playerid], 678.9570, 25.3431, 1042.8910, 135.00);
		SetActorVirtualWorld(player_actor_show[playerid], playerid);
	}
	if(clickedid == server_skin_show[3])
	{
		switch(GetPVarInt(playerid, !"click_skin"))
		{
			case 19: SetPVarInt(playerid, !"click_skin", 18), player_actor_skin_id[playerid] = 75, TextDrawSetSelectable(server_skin_show[2], true), TextDrawColor(server_skin_show[2], -1), TextDrawShowForPlayer(playerid, server_skin_show[2]);
			case 18: SetPVarInt(playerid, !"click_skin", 17), player_actor_skin_id[playerid] = 65;
			case 17: SetPVarInt(playerid, !"click_skin", 16), player_actor_skin_id[playerid] = 64;
			case 16: SetPVarInt(playerid, !"click_skin", 15), player_actor_skin_id[playerid] = 54;
			case 15: SetPVarInt(playerid, !"click_skin", 14), player_actor_skin_id[playerid] = 38;
			case 14: SetPVarInt(playerid, !"click_skin", 13), player_actor_skin_id[playerid] = 31;
			case 13: SetPVarInt(playerid, !"click_skin", 12), player_actor_skin_id[playerid] = 230;
			case 12: SetPVarInt(playerid, !"click_skin", 11), player_actor_skin_id[playerid] = 200;
			case 11: SetPVarInt(playerid, !"click_skin", 10), player_actor_skin_id[playerid] = 160;
			case 10: SetPVarInt(playerid, !"click_skin", 9), player_actor_skin_id[playerid] = 159;
			case 9: SetPVarInt(playerid, !"click_skin", 8), player_actor_skin_id[playerid] = 137;
			case 8: SetPVarInt(playerid, !"click_skin", 7), player_actor_skin_id[playerid] = 136;
			case 7: SetPVarInt(playerid, !"click_skin", 6), player_actor_skin_id[playerid] = 135;
			case 6: SetPVarInt(playerid, !"click_skin", 5), player_actor_skin_id[playerid] = 134;
			case 5: SetPVarInt(playerid, !"click_skin", 4), player_actor_skin_id[playerid] = 132;
			case 4: SetPVarInt(playerid, !"click_skin", 3), player_actor_skin_id[playerid] = 95;
			case 3: SetPVarInt(playerid, !"click_skin", 2), player_actor_skin_id[playerid] = 79;
			case 2: SetPVarInt(playerid, !"click_skin", 1), player_actor_skin_id[playerid] = 78, TextDrawSetSelectable(server_skin_show[3], false), TextDrawColor(server_skin_show[3], 0x757575FF), TextDrawShowForPlayer(playerid, server_skin_show[3]);
		}
		DestroyActor(player_actor_show[playerid]); 
		player_actor_show[playerid] = CreateActor(player_actor_skin_id[playerid], 678.9570, 25.3431, 1042.8910, 135.00);
		SetActorVirtualWorld(player_actor_show[playerid], playerid);
	}
	if(clickedid == server_skin_show[4])
	{
		ShowDialogSkin(playerid);
	}
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case 0:
		{
			if(!response)
			{
				SendClientMessage(playerid, WHITE, !"Вы добровольно отказались от процесса авторизации");
				SendClientMessage(playerid, WHITE, !"Используйте {76FF03}/q(quit){ffffff} для выхода из игры");
				KickPlayer(playerid);
			}
			if(response)
			{
				if(!strlen(inputtext)) return ShowDialogAuthorization(playerid);
				if(!strcmp(PlayerInfo[playerid][Password], inputtext, false))
				{
					SendClientMessage(playerid, BLUE, !"Авторизация прошла успешно!");
					LoadAccounts(playerid);
				}
				else
				{	
					switch(GetPVarInt(playerid, !"error_password"))
					{
						case 0: SendClientMessage(playerid, DEEP_ORANGE, !"Вы ввели неверный пароль.Осталось две попытки"), ShowDialogAuthorization(playerid);
						case 1: SendClientMessage(playerid, DEEP_ORANGE, !"Вы ввели неверный пароль.Осталась последняя попытка"), ShowDialogAuthorization(playerid);
						case 2:
						{
							SendClientMessage(playerid, DEEP_ORANGE, !"Превышено максимально допустимое количество попыток авторизации");
							SendClientMessage(playerid, WHITE, !"Используйте {76FF03}/q(quit){ffffff} для выхода из игры");
							KickPlayer(playerid);
						}
					}
					SetPVarInt(playerid, !"error_password", GetPVarInt(playerid, !"error_password") + 1);
				}
			}
		}
		case 1:
		{
			if(!response)
			{
				SendClientMessage(playerid, WHITE, !"Вы добровольно отказались от процесса регистрации");
				SendClientMessage(playerid, WHITE, !"Используйте {76FF03}/q(quit){ffffff} для выхода из игры");
				KickPlayer(playerid);
			}
			if(response)
			{
				if(strlen(inputtext) < 6) return SendClientMessage(playerid, DEEP_ORANGE, !"Минимальная длина пароля - 6 символов"), ShowDialogRegister(playerid);
				if(strlen(inputtext) > 20) return SendClientMessage(playerid, DEEP_ORANGE, !"Максимальная длина пароля - 20 символов"), ShowDialogRegister(playerid);
				strmid(PlayerInfo[playerid][Password], inputtext, 0, strlen(inputtext), 20);
				SetPVarInt(playerid, !"skin_select", 1);
				SetSpawnInfo(playerid, 0, 0, 678.9570, 25.3431, 1042.8910, 0.00, 0, 0, 0, 0, 0, 0);
				SpawnPlayer(playerid);
			}
		}
		case 2:
		{
			if(!response)
			{
				SelectTextDraw(playerid, 0x00d371FF);
			}
			if(response)
			{
				PlayerInfo[playerid][Skin] = player_actor_skin_id[playerid];
				PlayerInfo[playerid][Sex] = IsPlayerFemale(player_actor_skin_id[playerid]);
				static const sql_register[] = "INSERT INTO `Accounts`(`Name`, `Password`, `Skin`, `Sex`, `LastIP`, `RegIP`, `RegDate`) VALUES ('%s', '%s', %i, %i, '%s', '%s', %d)";
				array:string[sizeof(sql_register) + 1 - 2 + MAX_PLAYER_NAME - 2 + 20 - 2 + 3 - 2 + 1 - 2 + 16 - 2 + 16 - 2 + 10];
				format(string, sizeof(string), sql_register, PlayerInfo[playerid][Name], PlayerInfo[playerid][Password], PlayerInfo[playerid][Skin],
					PlayerInfo[playerid][Sex], PlayerInfo[playerid][IP], PlayerInfo[playerid][IP], gettime());
				mysql_function_query(server_database, string, false, "", "");
				DeletePVar(playerid, !"skin_select");
				DeletePVar(playerid, !"click_skin");
				DestroyActor(player_actor_show[playerid]);
				for(new i; i < sizeof(server_skin_show); i ++)  TextDrawHideForPlayer(playerid, server_skin_show[i]);
				SelectTextDraw(playerid, 0x00d371FF);
				CancelSelectTextDraw(playerid);
				LoadAccounts(playerid);
			}
		}
		case 3:
		{
			if(response)
			{
				SendClientMessage(playerid, WHITE, !"Вы трудоустроились {33FF00}грузчиком{ffffff} в строительную компанию {33FF00}Forest Building");
				SendClientMessage(playerid, WHITE, !"Следуйте к {d50000}красному маркеру{ffffff}, отмеченному на миникарте, для начала работы");
				job_building[playerid] = 1;
				job_building_money[playerid] = 0;
				job_building_bag[playerid] = 0;
				RandomCheckpointBuilding(playerid);
				switch(PlayerInfo[playerid][Sex])
				{
					case 0: SetPlayerSkin(playerid, 27);
					case 1: SetPlayerSkin(playerid, 131);
				}
			}
		}
		case 4:
		{
			if(response)
			{
				EndJobBuilding(playerid);
			}
		}
		case 5:
		{
			if(response)
			{
				SendClientMessage(playerid, WHITE, !"Вы трудоустроились {33FF00}сборщиком заготовок оружия{ffffff} в приозводственную компанию {33FF00}Forest Plant");
				SendClientMessage(playerid, WHITE, !"Следуйте к раздачному столику {33FF00}(зеленой стрелке){ffffff}, для начала работы");
				job_plant[playerid] = 1;
				job_plant_money[playerid] = 0;
				RandomPickuptPlant(playerid);
				switch(PlayerInfo[playerid][Sex])
				{
					case 0: SetPlayerSkin(playerid, 206);
					case 1: SetPlayerSkin(playerid, 131);
				}
			}
		}
		case 6:
		{
			if(response)
			{
				EndJobPlant(playerid);
			}
		}
	}
	return 1;
}

stock RandomCheckpointBuilding(playerid)
{
	switch(random(3))
	{
		case 0: SetPlayerCheckpoint(playerid, 2675.5959, 867.1896, 10.9395, 1.3);
		case 1: SetPlayerCheckpoint(playerid, 2676.9465, 867.1896, 10.9395, 1.3);
		case 2: SetPlayerCheckpoint(playerid, 2678.0964, 867.1896, 10.9395, 1.3);
	}
	SetTypeCheckpoint[playerid] = JOB_BUILDING_TAKE;
}

stock RandomCheckpointBuilding_2(playerid)
{
	switch(random(3))
	{
		case 0: SetPlayerCheckpoint(playerid, 2589.4485, 798.8741, 10.9545, 1.3);
		case 1: SetPlayerCheckpoint(playerid, 2587.9939, 787.8308, 10.9545, 1.3);
		case 2: SetPlayerCheckpoint(playerid, 2586.4653, 790.6970, 10.9545, 1.3);
	}
	SetTypeCheckpoint[playerid] = JOB_BUILDING_PUT;
}

new 
	Float: checkpoint_x[MAX_PLAYERS],
	Float: checkpoint_y[MAX_PLAYERS],
	Float: checkpoint_z[MAX_PLAYERS];

stock RandomPickuptPlant(playerid)
{
	switch(random(2))
	{
		case 0: return job_plant_pickup_give[playerid] = CreateDynamicPickup(19134, 23, 24.2820, 4.1392, 1001.6, 3, 3, playerid, 300.00);
		case 1: return job_plant_pickup_give[playerid] = CreateDynamicPickup(19134, 23, 24.2820, 7.6400, 1001.6, 3, 3, playerid, 300.00);
	}
	return true;
}

stock EndJobBuilding(playerid)
{
	static const info[] = "Рабочий день завершен.Всего заработанно: {33FF00}%i$";
	array:string[sizeof(info) - 2 + 9 + 1];
	new money = job_building_money[playerid];
	format(string, sizeof(string), info, money);
	SendClientMessage(playerid, WHITE, string);
	SetPlayerSkin(playerid, PlayerInfo[playerid][Skin]);
	PlayerInfo[playerid][Money] = PlayerInfo[playerid][Money] + money;
	SetPlayerMoney(playerid, money);
	job_building[playerid] = 0;
	job_building_money[playerid] = 0;
	job_building_bag[playerid] = 0;
	ClearPlayerAnim(playerid);
	RemovePlayerAttachedObject(playerid, 1);
	DisablePlayerCheckpoint(playerid);
}

stock EndJobPlant(playerid)
{
	static const info[] = "Рабочий день завершен.Всего заработанно: {33FF00}%i$";
	array:string[sizeof(info) - 2 + 9 + 1];
	new money = job_plant_money[playerid];
	format(string, sizeof(string), info, money);
	SendClientMessage(playerid, WHITE, string);
	SetPlayerSkin(playerid, PlayerInfo[playerid][Skin]);
	PlayerInfo[playerid][Money] = PlayerInfo[playerid][Money] + money;
	GivePlayerMoney(playerid, money);
	job_plant[playerid] = 0;
	job_plant_money[playerid] = 0;
	ClearPlayerAnim(playerid);
	RemovePlayerAttachedObject(playerid, 2), RemovePlayerAttachedObject(playerid, 3), RemovePlayerAttachedObject(playerid, 4);
	DisablePlayerCheckpoint(playerid);
	DestroyDynamicPickup(job_plant_pickup_give[playerid]);
	SetPVarInt(playerid, "BrakPlant", 0);
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

public OnPlayerEnterDynamicCP(playerid, checkpointid)
{
	if(checkpointid == player_help_checkpoint[playerid][0] || checkpointid == player_help_checkpoint[playerid][1]) return ShowDialogHelp(playerid);
	return 1;
}

public OnPlayerPickUpDynamicPickup(playerid, pickupid)
{
	if(PickupInfo[playerid][pickup_id] == pickupid)
		if(PickupInfo[playerid][pickup_time] > gettime())
			return 0;
	if(pickupid == player_pickup_eat[0] || pickupid == player_pickup_eat[1] || pickupid == player_pickup_eat[2] || pickupid == player_pickup_eat[3])
	{
		GiveEat(playerid);
	}
	if(pickupid == pickup_building_job[0])
	{
		switch(job_building[playerid])
		{
			case 0:  ShowPlayerDialog(playerid, 3, DIALOG_STYLE_MSGBOX, !"{1976D2}Трудоустройство", !"{ffffff}Вы действительно хотите начать рабочий день?", !"Да", !"Нет");
			case 1:  
			{
				static const info[] = 
					!"{ffffff}Вы действительно хотите завершить рабочий день?\n";
				array:string[(sizeof(info) / 4) + 77];
				string = info;
				if(job_building_money[playerid] >= 1)
				{
					static const money[] = "Заработанная плата {33FF00}(%i$){ffffff} будет выданна на руки";
					array:string_2[sizeof(money) - 2 + 15 + 1];
					format(string_2, sizeof(string_2), money, job_building_money[playerid]);
					string = info;
					strcat(string, string_2);
				}
				ShowPlayerDialog(playerid, 4, DIALOG_STYLE_MSGBOX, !"{1976D2}Трудоустройство", string, !"Да", !"Нет");
			}
		}
	}
	if(pickupid == pickup_building_job[1])
	{
		static const info[] = 
			!"{ffffff}Добро пожаловать в строительную компанию {33FF00}Forest Building!{ffffff}\n"\
			"Здесь вы можете заработать деньги за перенос мешков с цементов\n"\
			"Для начала работы, следуйте к иконке синей рубашки\n"\
			"(она дополнительно помечена на миникарте значком трактора)\n\n"\
			"{ffffff}Плана за один мешок: {1e88e5}~ 58$ (50$ - 65$){ffffff}\n"\
			"Средняя зарплата за час работы: {1e88e5}~ 5626{ffffff}";
		const string_length = 
			(sizeof(info) - 1) * cellbits / charbits + 1; 	
		array:string[string_length char]; 
		string = info;
		ShowPlayerDialog(playerid, 999, DIALOG_STYLE_MSGBOX, !"{1976D2}Информация", string, !"Закрыть", !"");
			
	}
	if(pickupid == pickup_city_hall[0])
	{
	    SetPlayerFacingAngle(playerid, 88.2497);
	    SetPlayerPos(playerid, 252.3592, 166.5846, 1087.5798);
	    SetPlayerInterior(playerid, 2);
	    SetPlayerVirtualWorld(playerid, 1);
	    SetCameraBehindPlayer(playerid);
	}
	if(pickupid == pickup_city_hall[1])
	{
        SetPlayerPos(playerid, 252.3592, 166.5846, 1087.5798);
        SetPlayerInterior(playerid, 2);
        SetPlayerVirtualWorld(playerid, 2);
        SetPlayerFacingAngle(playerid, 88.2497);
        SetCameraBehindPlayer(playerid);
	}
	if(pickupid == pickup_city_hall[2])
	{
        SetPlayerPos(playerid, 252.3592, 166.5846, 1087.5798);
        SetPlayerInterior(playerid, 2);
        SetPlayerVirtualWorld(playerid, 3);
        SetPlayerFacingAngle(playerid, 88.2497);
        SetCameraBehindPlayer(playerid);
	}
	if(pickupid == pickup_city_hall[3])
	{
		switch(GetPlayerVirtualWorld(playerid))
		{
		    case 1: SetPlayerPos(playerid, 1481.1492, -1769.2726, 18.7958), SetPlayerFacingAngle(playerid, 1.3951);
		    case 2: SetPlayerPos(playerid, -2762.9294, 375.7277, 5.8298), SetPlayerFacingAngle(playerid, 271.1739);
		    case 3: SetPlayerPos(playerid, 2386.7754, 2466.0608, 10.8203), SetPlayerFacingAngle(playerid, 88.3934);
		}
		SetCameraBehindPlayer(playerid);
		SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
	}
	if(pickupid == pickup_city_hall[4])
	{
		switch(GetPlayerVirtualWorld(playerid))
		{
		    case 1: SetPlayerPos(playerid, 1409.9930, -1790.8151, 13.5469), SetPlayerFacingAngle(playerid, 89.4426);
		    case 2: SetPlayerPos(playerid, -2807.4194, 375.1025, 4.5083), SetPlayerFacingAngle(playerid, 93.2026);
		    case 3: SetPlayerPos(playerid, 2518.9844, 2448.1782, 10.8203), SetPlayerFacingAngle(playerid, 270.8641);
		}
		SetCameraBehindPlayer(playerid);
		SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
	}
	if(pickupid == pickup_city_hall[5])
	{
		SetPlayerVirtualWorld(playerid, 1);
		SetPlayerPos(playerid, 234.0399, 184.5301, 1087.5829); 
		SetPlayerFacingAngle(playerid, 89.1663);
		SetCameraBehindPlayer(playerid);
		SetPlayerInterior(playerid, 2);
	}
	if(pickupid == pickup_city_hall[6])
	{
		SetPlayerVirtualWorld(playerid, 2);
		SetPlayerPos(playerid, 234.0399, 184.5301, 1087.5829); 
		SetPlayerFacingAngle(playerid, 89.1663);
		SetCameraBehindPlayer(playerid);
		SetPlayerInterior(playerid, 2);
	}
	if(pickupid == pickup_city_hall[7])
	{
		SetPlayerVirtualWorld(playerid, 3);
		SetPlayerPos(playerid, 234.0399, 184.5301, 1087.5829); 
		SetPlayerFacingAngle(playerid, 89.1663);
		SetCameraBehindPlayer(playerid);
		SetPlayerInterior(playerid, 2);
	}
	if(pickupid == pickup_city_hall[8])
	{
		SetPlayerPos(playerid, 222.4418, 160.1506, 1087.5743); 
		SetPlayerFacingAngle(playerid, 268.8576);
		SetCameraBehindPlayer(playerid);
	}
	if(pickupid == pickup_city_hall[9])
	{
		SetPlayerPos(playerid, 216.7626, 169.2998, 1093.3956); 
		SetPlayerFacingAngle(playerid, 180.1835);
		SetCameraBehindPlayer(playerid);
	}
	if(pickupid == pickup_plant_job[0])
	{
		SetPlayerPos(playerid, 30.5390, 0.3367, 1001.6033); 
		SetPlayerFacingAngle(playerid, 178.2332);
		SetPlayerVirtualWorld(playerid, 3);
		SetPlayerInterior(playerid, 3);
		SetCameraBehindPlayer(playerid);
	}
	if(pickupid == pickup_plant_job[1])
	{
		if(job_plant[playerid] == 1)
		{
			SendClientMessage(playerid, -1, "Вы покинилу территорию производственного цеха.");
		}
		SetPlayerPos(playerid, -89.9689, -300.5433, 2.7646); 
		SetPlayerFacingAngle(playerid, 89.7545);
		SetPlayerVirtualWorld(playerid, 0);
		SetPlayerInterior(playerid, 0);
		SetCameraBehindPlayer(playerid);
	}
	if(pickupid == pickup_plant_job[2])
	{
		switch(job_plant[playerid])
		{
			case 0:  ShowPlayerDialog(playerid, 5, DIALOG_STYLE_MSGBOX, !"{1976D2}Трудоустройство", !"{ffffff}Вы действительно хотите начать рабочий день?", !"Да", !"Нет");
			case 1:  
			{
				static const plant_info_money[] = !"{ffffff}Вы действительно хотите завершить рабочий день?\n";
				array:string[(sizeof(info) / 4) + 77];
				string = plant_info_money;
				if(job_plant_money[playerid] >= 1)
				{
					static const money[] = "Заработанная плата {33FF00}(%i$){ffffff} будет выданна на руки";
					array:string_2[sizeof(money) - 2 + 15 + 1];
					format(string_2, sizeof(string_2), money, job_plant_money[playerid]);
					string = plant_info_money;
					strcat(string, string_2);
				}
				ShowPlayerDialog(playerid, 6, DIALOG_STYLE_MSGBOX, !"{1976D2}Трудоустройство", string, !"Да", !"Нет");
			}
		}
	}
	if(job_plant[playerid] == 1)
	{
		for(new i = 0; i <= 10; i ++)
		{
			if(pickupid == job_plant_pickup[playerid][i])
			{
				DestroyDynamicPickup(job_plant_pickup_give[playerid]);
				printf("+++");
				if(job_plant_metal[playerid] == false)
					return SendClientMessage(playerid, WHITE, !"Возьмите металл у раздаточного стола");
				if(table_job_plant_used[i] == true) 
					return SendClientMessage(playerid, GRAY, !"Столик занят.Найдите другой");
				for(new o = 0; o <= 10; o ++)
					DestroyDynamicPickup(job_plant_pickup[playerid][o]);
				RemovePlayerAttachedObject(playerid, 2);
				RemovePlayerAttachedObject(playerid, 3);
				switch(i)
				{
					case 0:
					{
						SetPlayerPos(playerid, 7.1339, 5.8144, 1001.6033);
						SetPlayerFacingAngle(playerid, 0.0000);
						table_job_plant_object[i] = CreateDynamicObject(2035, 7.149, 6.554, 1001.563, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
					}
					case 1:
					{
						SetPlayerPos(playerid, 4.6684, 5.8144, 1001.6033);
						SetPlayerFacingAngle(playerid, 0.0000);
						table_job_plant_object[i] = CreateDynamicObject(2035, 4.789, 6.554, 1001.563, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
					}
					case 2:
					{
						SetPlayerPos(playerid, 2.3386, 5.8144, 1001.6033);
						SetPlayerFacingAngle(playerid, 0.0000);
						table_job_plant_object[i] = CreateDynamicObject(2035, 2.419, 6.554, 1001.563, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
					}
					case 3:
					{
						SetPlayerPos(playerid, 0.0505, 5.8144, 1001.6033);
						SetPlayerFacingAngle(playerid, 0.0000);
						table_job_plant_object[i] = CreateDynamicObject(2035, 0.059, 6.554, 1001.563, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
					}
					case 4:
					{
						SetPlayerPos(playerid, -2.3096, 5.8144, 1001.6033);
						SetPlayerFacingAngle(playerid, 0.0000);
						table_job_plant_object[i] = CreateDynamicObject(2035, -2.290, 6.554, 1001.563, 0.000, 0.000, 0.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
					}
					case 5:
					{
						SetPlayerPos(playerid, -2.3096, -7.9683, 1001.6033);
						SetPlayerFacingAngle(playerid, 180.0000);
						table_job_plant_object[i] = CreateDynamicObject(2035, -2.290, -8.7300, 1001.563, 0.000, 0.000, 180.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
					}
					case 6:
					{
						SetPlayerPos(playerid, 0.0505, -7.9683, 1001.6033);
						SetPlayerFacingAngle(playerid, 180.0000);
						table_job_plant_object[i] = CreateDynamicObject(2035, 0.059, -8.7300, 1001.563, 0.000, 0.000, 180.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
					}
					case 7:
					{
						SetPlayerPos(playerid, 2.3386, -7.9683, 1001.6033);
						SetPlayerFacingAngle(playerid, 180.0000);
						table_job_plant_object[i] = CreateDynamicObject(2035, 2.419, -8.7300, 1001.563, 0.000, 0.000, 180.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
					}
					case 8:
					{
						SetPlayerPos(playerid, 4.6684, -7.9683, 1001.6033);
						SetPlayerFacingAngle(playerid, 180.0000);
						table_job_plant_object[i] = CreateDynamicObject(2035, 4.789, -8.7300, 1001.563, 0.000, 0.000, 180.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
					}
					case 9:
					{
						SetPlayerPos(playerid, 7.0309, -7.9900, 1001.6033);
						SetPlayerFacingAngle(playerid, 180.0000);
						table_job_plant_object[i] = CreateDynamicObject(2035, 7.149, -8.7300, 1001.563, 0.000, 0.000, 180.000, 3, 3, -1, STREAMER_OBJECT_DISTANCE, STREAMER_OBJECT_DRAW_DISTANCE);
					}
				}
				SetPlayerAttachedObject(playerid, 2, 18644, 6, 0.082242, 0.039213, 0.000000, 15.000000, -5.000000, 0.000000, 1.000000, 1.000);
				SetPlayerAttachedObject(playerid, 3, 18635, 5, 0.0, 0.044200, -0.060892, 156.370300, 0.0, 0.0, 1.0, 1.0, 1.0);
				ApplyAnimation(playerid, !"OTB", !"BETSLP_LOOP", 4.1, 1, 0, 0, 0, 0);
				table_job_plant_used[i] = true;
				player_table_plant[playerid] = i;
				SetTimerEx(!"GivePlantBox", 6500, false, "ii", playerid, i);
				break;
			}
		}
	}
	if(pickupid == job_plant_pickup_give[playerid])
	{
		if(job_plant[playerid] == 0)
			return false;
		if(job_plant_metal[playerid] == true)
			return true;
		switch(random(3))
		{
			case 0:
			{
				GameTextForPlayer(playerid, !"~b~~h~ + 3 kg", 2000, 1); 
				plant_metall = plant_metall - 3;
				
			}
			case 1:
			{
				GameTextForPlayer(playerid, !"~b~~h~ + 4 kg", 2000, 1); 
				plant_metall = plant_metall - 4;
			}
			case 2:
			{
				GameTextForPlayer(playerid, !"~b~~h~ + 5 kg", 2000, 1); 
				plant_metall = plant_metall - 5;
			}
		}
		if(GetPVarInt(playerid, "vJobPlant") == 0)
		{
			SendClientMessage(playerid, WHITE, !"Для начала работы, проследуйте к одному из {33FF00}свободных столиков");
		}
		if(GetPVarInt(playerid, "vJobPlant") == 1)
		{
			SendClientMessage(playerid, WHITE, "Продолжайте работу в том же духе");
			SendClientMessage(playerid, WHITE, "Завершить рабочий день и получить зарплату вы можете в любой момент, встав на иконку {1976D2}синей рубашки");
			SetPVarInt(playerid, "vJobPlant", 2);
		}
		SetPVarInt(playerid, "BrakPlant", 0);
		job_plant_metal[playerid] = true;
		job_plant_pickup[playerid][0] = CreateDynamicPickup(19134, 23, 7.1339, 5.8144, 1001.6033, 3, 3, playerid, 0.5);
		job_plant_pickup[playerid][1] = CreateDynamicPickup(19134, 23, 4.7567, 5.8144, 1001.6033, 3, 3, playerid, 0.5);
		job_plant_pickup[playerid][2] = CreateDynamicPickup(19134, 23, 2.3795, 5.8144, 1001.6033, 3, 3, playerid, 0.5);
		job_plant_pickup[playerid][3] = CreateDynamicPickup(19134, 23, 0.0023, 5.8144, 1001.6033, 3, 3, playerid, 0.5);
		job_plant_pickup[playerid][4] = CreateDynamicPickup(19134, 23, -2.3749, 5.8144, 1001.6033, 3, 3, playerid, 0.5);
		job_plant_pickup[playerid][5] = CreateDynamicPickup(19134, 23, -2.3749, -7.9900, 1001.6033, 3, 3, playerid, 0.5);
		job_plant_pickup[playerid][6] = CreateDynamicPickup(19134, 23, 0.0023, -7.9900, 1001.6033, 3, 3, playerid, 0.5);
		job_plant_pickup[playerid][7] = CreateDynamicPickup(19134, 23, 2.3795, -7.9900, 1001.6033, 3, 3, playerid, 0.5);
		job_plant_pickup[playerid][8] = CreateDynamicPickup(19134, 23, 4.7567, -7.9900, 1001.6033, 3, 3, playerid, 0.5);
		job_plant_pickup[playerid][9] = CreateDynamicPickup(19134, 23, 7.1339, -7.9900, 1001.6033, 3, 3, playerid, 0.5);
		return true;
	}
	PickupInfo[playerid][pickup_id] = pickupid;
	PickupInfo[playerid][pickup_time] = gettime() + 5;
	return 1;
}

public IsPlayerAccounts(playerid)
{
	new rows, fields;
    cache_get_data(rows, fields);
	if(rows)
	{
		cache_get_field_content(0, !"Password", PlayerInfo[playerid][Password], server_database, !20);
		ShowDialogAuthorization(playerid);
	}
	else
	{
		ShowDialogRegister(playerid);
	}
}

new fuel = 0;

@ServerTime();
@ServerTime()
{
	if(server_approachability == false)
		MySQL_Connect();
	switch(random(80))
	{
		case 17:
		{
			fuel = random(3) + 1;
			if(tank[0] + fuel <= 75000)
			{
				tank[0] = tank[0] + fuel;
				UpdateRefinery();
			}
		}
		case 15:
		{
			fuel = random(3) + 1;
			if(tank[1] + fuel <= 75000)
			{
				tank[1] = tank[1] + fuel;
				UpdateRefinery();
			}
		}
		case 12:
		{
			fuel = random(3) + 1;
			if(tank[2] + fuel <= 75000)
			{
				tank[2] = tank[2] + fuel;
				UpdateRefinery();
			}
		}
		case 4:
		{
			fuel = random(3) + 1;
			if(tank[3] + fuel <= 75000)
			{
				tank[3] = tank[3] + fuel;
				UpdateRefinery();
			}
		} 
	}
	//new time;
	//gettime(time, _, _);
	//SetWorldTime(time);
	foreach(new i: Player)
	{
		if(job_plant[i])
		{
			UpdatePlantStore();
			break;
		}
	}
	return SetTimer(!"@ServerTime", 1000, false);
}

@PlayerTime(playerid);
@PlayerTime(playerid)
{
	//new string[144];
	new
            Float:fPX, Float:fPY, Float:fPZ,
            Float:fVX, Float:fVY, Float:fVZ;
	GetPlayerCameraPos(playerid, fPX, fPY, fPZ);
	GetPlayerCameraFrontVector(playerid, fVX, fVY, fVZ);
		
	//format(string, sizeof(string), "%f %f %f\n%f %f %f", fPX, fPY, fPZ, fVX, fVY, fVZ);
//SendClientMessage(playerid, -1, string);
	if(IsPlayerInAnyVehicle(playerid))
	{
		if(fPY == -1039.351562)
		{
			if(PlayerInfo[playerid][Money] < 500)
			{
				SendClientMessage(playerid, -1, "Починка стоит 500$");
				SetVehicleHealth(GetPlayerVehicleID(playerid), 999.00);
				ResetPlayerMoney(playerid);
				GivePlayerMoney(playerid, 0);
				PlayerInfo[playerid][Money] = 0;
			}	
			
		}
	}
	if(player_logged[playerid] == true)
	{
		new anim = GetPlayerAnimationIndex(playerid);
		
		//new string[144];
		//format(string, sizeof(string), "%d", GetPlayerAnimationIndex(playerid));
		//SendClientMessage(playerid, GRAY, string);
		if(GetPlayerMoney(playerid) != PlayerInfo[playerid][Money])
		{
			ResetPlayerMoney(playerid);
			GivePlayerMoney(playerid, PlayerInfo[playerid][Money]);
		}
		new Float: level_hp;
		GetPlayerHealth(playerid, level_hp);
		if(PlayerInfo[playerid][Health] < level_hp)
		{
			SetPlayerHealth(playerid, PlayerInfo[playerid][Health]);
		}
		if(job_building[playerid] == 1)
		{
			new Float: player_pos_x, Float: player_pos_y, Float: player_pos_z;
			GetPlayerPos(playerid, player_pos_x, player_pos_y, player_pos_z);
			if(player_pos_x >= 2721.9004 || player_pos_x <= 2552.4924 || player_pos_y >= 917.1127 || player_pos_y <= 778.2700 || anim == 1064)
			{
				EndJobBuilding(playerid);
			}
		}
		if(job_plant[playerid] == 1)
		{
			switch(SetTypeCheckpoint[playerid])
			{
				case JOB_PLANT_PUT:
				{
					if(IsPlayerInRangeOfPoint(playerid, 1.0, checkpoint_x[playerid], checkpoint_y[playerid], checkpoint_z[playerid]))
					{
						DisablePlayerCheckpoint(playerid);
						RandomPickuptPlant(playerid);
						SendClientMessage(playerid, WHITE, "Вы принесли на склад цеха {33FF00}один ящик{ffffff} с оружейными заготовками");
						if(GetPVarInt(playerid, "vJobPlant") == 0)
						{
							SetPVarInt(playerid, "vJobPlant", 1);
							SendClientMessage(playerid, WHITE, "Вновь отправляйтесь к раздаточному столу, {33FF00}для получения металла");
						}
						RemovePlayerAttachedObject(playerid, 4);
						ClearPlayerAnim(playerid);
						ApplyAnimation(playerid, !"CARRY", !"putdwn", 4.1, 0, 0, 0, 0, 0, 0);
						job_plant_metal[playerid] = false;
						SetTypeCheckpoint[playerid] = NONE;
						plant_total_product = plant_total_product + 1;
						UpdatePlantProducts();
						job_plant_money[playerid] = job_plant_money[playerid] + (50 + random(16));
					}
				}
			}
			if(player_table_plant[playerid] >= 1)
			{
				if(anim != 949) 
					SetPVarInt(playerid, "BrakPlant", 1);
			}
		}
	}
	player_timer[playerid] = SetTimerEx(!"@PlayerTime", 1000, false, !"i", playerid);
	return 1;
}

@RequestClass(playerid);
@RequestClass(playerid)
{
	SetSpawnInfo(playerid, 0, PlayerInfo[playerid][Skin], 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 0, 0, 0);
	SpawnPlayer(playerid);  
	return true;
}

@Update(playerid);
@Update(playerid)
{
	return Streamer_Update(playerid);
}

@GiveEat(playerid);
@GiveEat(playerid)
{
	ApplyAnimation(playerid, !"CARRY", !"crry_prtial", 4.0, 1, 0, 0, 1, 1, 1);
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
	SetPlayerAttachedObject(playerid, 0, 2355, 1, 0.11, 0.334523, -0.267872, 109.200798, 116.924514, 310.923736, 1.025472, 1.000000, 1.000000);
	return true;
}

forward EatDelete();
public EatDelete()
{
	for(new i = 1; i < MAX_TRAYS_EAT; i ++)
	{
		if(eat[i][eat_time_drop] + 180 < gettime())
		{
			if(eat[i][eat_status] == 2)
			{
				DestroyDynamicObject(eat[i][eat_id]);
				DestroyDynamic3DTextLabel(eat[i][eat_text]);
				eat[i][eat_x] = 0.00;
				eat[i][eat_y] = 0.00;
				eat[i][eat_z] = 0.00;
				eat[i][eat_angle] = 0.00;
				eat[i][eat_virtualworld] = 0;
				eat[i][eat_interior] = 0;
				eat[i][eat_status] = 0;
			}
		}
	}
	return true;
}

forward GiveBag(playerid);
public GiveBag(playerid)
{
	ApplyAnimation(playerid, !"CARRY", !"crry_prtial", 4.0, 1, 0, 0, 1, 1, 1);
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
	SetPlayerAttachedObject(playerid, 1, 2060, 5, 0.01, 0.1, 0.2, 100, 10, 85);
}

forward GivePlantBox(playerid, table);
public GivePlantBox(playerid, table)
{
	plant_fuel = plant_fuel - ((random(3) + 3) * 4);
	player_table_plant[playerid] = 0;
	RemovePlayerAttachedObject(playerid, 2);
	RemovePlayerAttachedObject(playerid, 3);
	table_job_plant_used[table] = false;
	DestroyDynamicObject(table_job_plant_object[table]);
	if(GetPVarInt(playerid, "BrakPlant") == 1)
	{
		job_plant_metal[playerid] = false;
		ApplyAnimation(playerid, !"OTB", !"wtchrace_lose", 4.0, 0, 0, 0, 1, 0, 1);
		SetTimerEx(!"ClearAnim", 2000, false, "i", playerid);
		SetPVarInt(playerid, "BrakPlant", 0);
		SendClientMessage(playerid, WHITE, "Вы изготовили бракованную заготовку.С вашей зарплаты была {33FF00}удержана{ffffff} определенная сумма");
		SendClientMessage(playerid, WHITE, "Возьмите вновь {33FF00}металические заготовки{ffffff} и продолжайте работу");
		return true;
	}
	ApplyAnimation(playerid, !"CARRY", !"crry_prtial", 4.0, 1, 0, 0, 1, 1, 1);
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
	SetPlayerAttachedObject(playerid, 4, 2040, 1, 0.11, 0.36, 0.0, 90.0, 90.0, 2, 2, 2);
	SetTypeCheckpoint[playerid] = JOB_PLANT_PUT;
	checkpoint_x[playerid] = 20.7471, checkpoint_y[playerid] = -11.6339, checkpoint_z[playerid] = 1001.6033;
	SetPlayerCheckpoint(playerid, checkpoint_x[playerid], checkpoint_y[playerid], checkpoint_z[playerid] - 1, 1.5);
	SetPlayerChatBubble(playerid, "изготовил заготовку", 0xdd90ffFF, 15.0, 3000);
	return true;
}

forward LoadWarehouseAmmo();
public LoadWarehouseAmmo()
{
	new rows, fields;
	cache_get_data(rows, fields, server_database);
	if(rows)
	{
		warehouse_total_ammo = cache_get_field_content_int(0, !"Ammo", server_database);
		static const info[] = "Ящиков с патронами:\n %i штук";
		array:string[sizeof(info) - 2 + 1 + 15];
		format(string, sizeof(string), info, warehouse_total_ammo);
		warehouse_text = CreateDynamic3DTextLabel(string, YELLOW, -2220.2356, 2487.0645, 10.1269 + 1.2, 5.00, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0, -1, 5.00);
	}
}

forward LoadPlant();
public LoadPlant()
{
	new rows, fields;
	cache_get_data(rows, fields, server_database);
	if(rows)
	{
				
		plant_fuel = cache_get_field_content_int(0, !"Fuel", server_database);
		plant_metall = cache_get_field_content_int(0, !"Metall", server_database);
		plant_total_product = cache_get_field_content_int(0, !"Products", server_database);
		plant_info_store = CreateDynamic3DTextLabel(!" ", WHITE, 25.2934, 5.7675, 1002.0728 + 1, 10.00, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 3, 3, -1, 10.00);
		plant_info_street_store = CreateDynamic3DTextLabel(!" ", WHITE, -19.3325, -277.6135, 5.4297 + 5, 15.00, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0, -1, 15.00);
		plant_info_products = CreateDynamic3DTextLabel(" ", WHITE, 20.7471, -11.6339, 1002.0728 + 1, 10.00, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 3, 3, -1, 10.00);
		UpdatePlantStore();
		UpdatePlantProducts();
	}
}


forward LoadRefinery();
public LoadRefinery()
{
	new rows, fields;
	cache_get_data(rows, fields, server_database);
	if(rows)
	{
				
		tank[0] = cache_get_field_content_int(0, !"Tank_1", server_database);
		tank[1] = cache_get_field_content_int(0, !"Tank_2", server_database);
		tank[2] = cache_get_field_content_int(0, !"Tank_3", server_database);
		tank[3] = cache_get_field_content_int(0, !"Tank_4", server_database);
		tank_info_1 = CreateDynamic3DTextLabel("Информация", WHITE, 217.9251, 1371.3468, 11.0226 + 4, 15.00, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0, -1, 15.00);
		tank_info_2 = CreateDynamic3DTextLabel("Информация", WHITE, 218.0482, 1395.9663, 11.0226 + 4, 15.00, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0, -1, 15.00);
		tank_info_3 = CreateDynamic3DTextLabel("Информация", WHITE, 218.1711, 1420.5713, 11.0226 + 4, 15.00, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0, -1, 15.00);
		tank_info_4 = CreateDynamic3DTextLabel("Информация", WHITE, 218.2956, 1445.4922, 11.0226 + 4, 15.00, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0, -1, 15.00);
		UpdateRefinery();
	}
}

forward ClearAnim(playerid);
public ClearAnim(playerid)
{
	ClearPlayerAnim(playerid);
}

stock UpdatePlantStore()
{
	static const info[] = 
		"Топливо {33FF00}%i{ffffff}/{33FF00}250000{ffffff} литров\n"\
		"Металл {33FF00}%i{ffffff}/{33FF00}75000{ffffff} килограмм";
	array:string[sizeof(info) + 1 + ((-2 + 15) * 3) + 33];
	format(string, sizeof(string), info, plant_fuel, plant_metall);
	UpdateDynamic3DTextLabelText(plant_info_store, WHITE, string);
	strcat(string, !"\n\nИспользуйте {33FF00}/sellfuel{ffffff} для продажи топлива заводу");
	UpdateDynamic3DTextLabelText(plant_info_street_store, WHITE, string);
	return true;
}

stock UpdatePlantProducts()
{
	static const info[] = "Продукции на складе {33FF00}%i{ffffff} яшика(ов)";
	array:string[sizeof(info) + 1 + (-2 + 15)];
	format(string, sizeof(string), info, plant_total_product);
	UpdateDynamic3DTextLabelText(plant_info_products, WHITE, string);
}

stock SavePlant()
{
	static const info[] = "UPDATE `Plant` SET `Fuel` = '%i', `Metall` = '%i', `Products` = '%i'";
	array:string[sizeof(info) + 1 + ((-2 + 15) * 3)];
	format(string, sizeof(string), info, plant_fuel, plant_metall, plant_total_product);
	mysql_function_query(server_database, string, false, "", "");
}

stock UpdateRefinery()
{
	static const text[] = 
		"Цистерна {33FF00}№%i{ffffff}\n"\
		"Топлива {33FF00}%i{ffffff}/{33FF00}75000{ffffff} литров\n\n"\
		"Используйте {33FF00}/buyfuel{ffffff}, для покупки топлива";
	array:string[sizeof(text) - 2 + 1 - 2 + 5 + 1];
	format(string, sizeof(string), text, 1, tank[0]);
	UpdateDynamic3DTextLabelText(tank_info_1, WHITE, string);
	
	format(string, sizeof(string), text, 2, tank[1]);
	UpdateDynamic3DTextLabelText(tank_info_2, WHITE, string);
	
	format(string, sizeof(string), text, 3, tank[2]);
	UpdateDynamic3DTextLabelText(tank_info_3, WHITE, string);
	
	format(string, sizeof(string), text, 4, tank[3]);
	UpdateDynamic3DTextLabelText(tank_info_4, WHITE, string);
}

stock SaveRefinery()
{
	static const info[] = "UPDATE `Refinery` SET `Tank_1` = '%i', `Tank_2` = '%i', `Tank_3` = '%i', `Tank_4` = '%i'";
	array:string[sizeof(info) + 1 + ((-2 + 15) * 4)];
	format(string, sizeof(string), info, tank[0], tank[1], tank[2], tank[3]);
	mysql_function_query(server_database, string, false, "", "");
}

public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	if(playerid == INVALID_PLAYER_ID)
		return false;
	if(weaponid < 0 || weaponid > 46)
		return false;
	if(hittype < 0 || hittype > 4)
		return false;
	if(hitid < 0 || hitid > 4)
		return false;
	
	switch(weaponid)
	{
		case 1, 2, 4, 6, 7, 9, 15..18, 22, 26, 27, 28, 32, 35..41, 44, 45: return false;
	}
	
	switch(weaponid)
	{
		case WEAPON_SILENCED, WEAPON_DEAGLE:
		{
			player_gun_patr[playerid][1] = player_gun_patr[playerid][1] - 1;
			if(player_gun_patr[playerid][1] < 0) 
				player_gun_patr[playerid][1] = 0;
		}
		case WEAPON_SHOTGUN:
		{
			player_gun_patr[playerid][2] = player_gun_patr[playerid][2] - 1;
			if(player_gun_patr[playerid][2] < 0) 
				player_gun_patr[playerid][2] = 0;
		}
		case WEAPON_MP5:
		{
			player_gun_patr[playerid][3] = player_gun_patr[playerid][3] - 1; 
			if(player_gun_patr[playerid][3] < 0) 
				player_gun_patr[playerid][3] = 0;
		}
		case WEAPON_AK47, WEAPON_M4:
		{
			player_gun_patr[playerid][4] = player_gun_patr[playerid][4] - 1;
			if(player_gun_patr[playerid][4] < 0) 
				player_gun_patr[playerid][4] = 0;
		}
		case WEAPON_RIFLE, WEAPON_SNIPER:
		{
			player_gun_patr[playerid][5] = player_gun_patr[playerid][5] - 1; 
			if(player_gun_patr[playerid][5] < 0) 
				player_gun_patr[playerid][5] = 0;
		}
	}
    return 1;
}

public OnPlayerEditObject(playerid, playerobject, objectid, response, Float:fX, Float:fY, Float:fZ, Float:fRotX, Float:fRotY, Float:fRotZ)
{
	new Float:oldX, Float:oldY, Float:oldZ, Float:oldRotX, Float:oldRotY, Float:oldRotZ;
	GetObjectPos(objectid, oldX, oldY, oldZ);
	GetObjectRot(objectid, oldRotX, oldRotY, oldRotZ);
	if(!playerobject)
	{
	    if(!IsValidObject(objectid)) return 1;
	    SetObjectPos(objectid, fX, fY, fZ);		          
		SetObjectRot(objectid, fRotX, fRotY, fRotZ);
	}
 
	if(response == EDIT_RESPONSE_FINAL)
	{

	}
	if(response == EDIT_RESPONSE_CANCEL)
	{
		if(!playerobject)
		{
			SetObjectPos(objectid, oldX, oldY, oldZ);
			SetObjectRot(objectid, oldRotX, oldRotY, oldRotZ);
		}
		else
		{
			SetPlayerObjectPos(playerid, objectid, oldX, oldY, oldZ);
			SetPlayerObjectRot(playerid, objectid, oldRotX, oldRotY, oldRotZ);
		}
	}
	return 1;
}

public OnEnterExitModShop(playerid, enterexit, interiorid)
{
    SendClientMessage(playerid, -1, "Мачо");
    return 1;
}


public LoadPlayerAccounts(playerid)
{
	new rows, fields;
	cache_get_data(rows, fields, server_database);
	if(rows)
	{
		PlayerInfo[playerid][Money] = cache_get_field_content_int(0, !"Money", server_database);
		PlayerInfo[playerid][Health] = cache_get_field_content_float(0, !"Health", server_database);
		PlayerInfo[playerid][Skin] = cache_get_field_content_int(0, !"Skin", server_database);
		PlayerInfo[playerid][Sex] = cache_get_field_content_int(0, !"Sex", server_database);
		PlayerInfo[playerid][Admin] = cache_get_field_content_int(0, !"Admin", server_database);
		PlayerInfo[playerid][Level] = cache_get_field_content_int(0, !"Level", server_database);
		switch(random(10))
		{
			case 0:  SetSpawnInfo(playerid, 0, PlayerInfo[playerid][Skin], 1157.2451, -1769.7826, 16.59, 0.8296, 0, 0, 0, 0, 0, 0);
			case 1:  SetSpawnInfo(playerid, 0, PlayerInfo[playerid][Skin], 1154.2694, -1769.7826, 16.59, 0.8296, 0, 0, 0, 0, 0, 0);
			case 2:  SetSpawnInfo(playerid, 0, PlayerInfo[playerid][Skin], 1151.2147, -1769.7826, 16.59, 0.8296, 0, 0, 0, 0, 0, 0);
			case 3:  SetSpawnInfo(playerid, 0, PlayerInfo[playerid][Skin], 1148.0356, -1769.7826, 16.59, 0.8296, 0, 0, 0, 0, 0, 0);
			case 4:  SetSpawnInfo(playerid, 0, PlayerInfo[playerid][Skin], 1143.5479, -1769.7826, 16.59, 272.0720, 0, 0, 0, 0, 0, 0);
			case 5:  SetSpawnInfo(playerid, 0, PlayerInfo[playerid][Skin], 1757.8281, -1889.0309, 13.55, 269.5861, 0, 0, 0, 0, 0, 0);
			case 6:  SetSpawnInfo(playerid, 0, PlayerInfo[playerid][Skin], 1757.8281, -1893.4250, 13.55, 269.5861, 0, 0, 0, 0, 0, 0);
			case 7:  SetSpawnInfo(playerid, 0, PlayerInfo[playerid][Skin], 1757.8281, -1896.8391, 13.56, 269.5861, 0, 0, 0, 0, 0, 0);
			case 8:  SetSpawnInfo(playerid, 0, PlayerInfo[playerid][Skin], 1757.8281, -1900.1844, 13.56, 269.5861, 0, 0, 0, 0, 0, 0);
			case 9:  SetSpawnInfo(playerid, 0, PlayerInfo[playerid][Skin], 1757.8281, -1903.2236, 13.56, 269.5861, 0, 0, 0, 0, 0, 0);
		}
		if(PlayerInfo[playerid][Admin] >= 1)
		{
			switch(PlayerInfo[playerid][Admin])
			{
				case 1: SendClientMessage(playerid, -1, !"Вы вошли как администратор {33FF00}первого{ffffff} уровня");
				case 2: SendClientMessage(playerid, -1, !"Вы вошли как администратор {33FF00}второго{ffffff} уровня");
				case 3: SendClientMessage(playerid, -1, !"Вы вошли как администратор {33FF00}третьего{ffffff} уровня");
				case 4: SendClientMessage(playerid, -1, !"Вы вошли как администратор {33FF00}четвертого{ffffff} уровня");
				case 5: SendClientMessage(playerid, -1, !"Вы вошли как администратор {33FF00}пятого{ffffff} уровня");
				case 6..7: SendClientMessage(playerid, -1, !"Вы вошли как {FF9900}главный администратор");
			}
		}
		SetPlayerScore(playerid, PlayerInfo[playerid][Level]);
		SetPlayerHealth(playerid, PlayerInfo[playerid][Health]);
		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, 0);
		TogglePlayerSpectating(playerid, false);
		player_logged[playerid] = true;
	}
}

public OnPlayerCommandReceived(playerid, cmdtext[])
{
	if(IsPlayerConnected(playerid) == 0) return 0;
	if(player_logged[playerid] == false) return 0;
    return 1;
}  

stock ShowDialogAuthorization(playerid)
{
	static const str0[] = 
        !"{ffffff}Добро пожаловать на сервер {1e88e5}Forest Role Play!\n"\ 
        "{ffffff}Ваш аккаунт {64dd17}"; 
    static const str1[] = 
        !"{ffffff} уже зарегистрирован\n\n"\ 
        "Для продолжения игры, Вам необходимо пройти\n"\ 
        "авторизацию.Введите свой пароль в окошко ниже.";
    const string_length = 
        (sizeof(str0) - 1) * cellbits / charbits + 
        MAX_PLAYER_NAME + 
        (sizeof(str1) - 1) * cellbits / charbits + 
        1; 
    array:string[string_length char]; 
    string = str0; 
    strcat(string, PlayerInfo[playerid][Name]); 
    strcat(string, str1); 
    return ShowPlayerDialog(playerid, 0, DIALOG_STYLE_INPUT, !"{1976D2}Авторизация", string, !"Вход", !"Отмена");
}

stock ShowDialogRegister(playerid) 
{ 
    static const str0[] = 
        !"{ffffff}Добро пожаловать на сервер {1e88e5}Forest Role Play!"\ 
        "\n{ffffff}Ваш аккаунт {64dd17}"; 
    static const str1[] = 
        !"{ffffff} еще не зарегистрирован\n\n"\ 
        "Для начала игры, Вам необходимо пройти регистрацию\n"\ 
        "Введите желаемый пароль в окошко ниже.";
    const string_length = 
        (sizeof(str0) - 1) * cellbits / charbits + 
        MAX_PLAYER_NAME + 
        (sizeof(str1) - 1) * cellbits / charbits + 
        1; 
    array:string[string_length char]; 
    string = str0; 
    strcat(string, PlayerInfo[playerid][Name]); 
    strcat(string, str1); 
    return ShowPlayerDialog(playerid, 1, DIALOG_STYLE_INPUT, !"{1976D2}Регистрация", string, !"Далее", !"Отмена"); 
}

stock ShowDialogSkin(playerid)
{
	static const str0[] = 
        !"{ffffff}Вы уверены в своем выборе?Игровой скин после регистрации можно\n"\ 
        "будет изменить только в магазинах одежды, за виртуальные средства\n"\
		"В случае необходимости, пол персонажа (";
	static const str1[] = 
        !"{ffffff}) можно будет\n"\ 
        "сменить в любой из трех больниц, так же за виртуальные средства";
	const string_length = 
        (sizeof(str0) - 1) * cellbits / charbits + 
        MAX_PLAYER_NAME + 
        (sizeof(str1) - 1) * cellbits / charbits + 
        1; 	
	array:string[string_length char];
	array:sex[16]; 
    string = str0;
	format(sex, sizeof(sex), "%s", (IsPlayerFemale(player_actor_skin_id[playerid]) == 0) ? ("{1E88E5}мужской") : ("{EC407A}женский)"));
	strcat(string, sex); 
    strcat(string, str1); 
	return ShowPlayerDialog(playerid, 2, DIALOG_STYLE_MSGBOX, !"{1976D2}Регистрация", string, !"Далее", !"Отмена"); 
}

stock ShowDialogHelp(playerid)
{
	static const text[] = 
		!"{33FF00}1. {ffffff}Первым делом заработайте деньги. Они упростят вашу игру и помогут в решении многих вопросов внутри игры.\n"\ 
		"\tЕсли вы новичок - отправляйтесь на начальные работы: *название 1* *название 2* *название 3*.\n\n"\ 
		"{33FF00}2. {ffffff}Обзаведитесь нужными для себя лицензиями (лицензия на управление автомобилем, водным и летным транспортом, лицензия на оружие).\n"\ 
		"\tЛицензию на управление автомобилем можно получить в автошколе, сдав инструктору теоретическую и практическую часть экзамена.\n"\ 
		"\tДругие лицензии можно будет приобрести в любое время у лицензера автошколы за игровую валюту.\n"\ 
		"\tВедите себя адекватно на дорогах и не нарушайте ПДД, иначе сотрудники полиции могут лишить вас лицензии.\n\n"\ 
		"{33FF00}3. {ffffff}По достижению 3 уровня Вы можете отправиться на призыв в армию или на собеседование в государственные структуры.\n"\ 
		"\tМожете начать полноценную карьеру в какой-либо организации либо зарабатывать игровую валюту на доступных для вашего уровня работах.\n\n"\ 
		"{ffffff}Постройте свою репутацию с нуля! Вы можете править штатом, быть авторитетным бандитом, лучшим таксистом. Все зависит только от Вашего выбора!\n"\ 
		"Приятной игры на {1976D2}Forest Role Play\n";
	array:string[sizeof(text) + 1];
	string = text;
	return ShowPlayerDialog(playerid, 999, DIALOG_STYLE_MSGBOX, !"{1976D2}Помощь по игре", string, !"Закрыть", !"");
}

stock KickPlayer(playerid)
{
	SetTimerEx(!"PlayerKick", 100, false, !"i", playerid);
}

stock IsPlayerFemale(skin)
{
	static const female_skin[84][1 char] = 
	{		
		{9}, {10}, {11}, {12}, {13}, {31}, {38}, {39}, {40}, {41}, {53}, {54}, {55}, {56}, {63}, {64}, {65}, {69}, {75}, {76}, {77}, {85}, {87}, 
		{88}, {89}, {90}, {91}, {92}, {93}, {129}, {130}, {131}, {138}, {139}, {140}, {141}, {145}, {148}, {150}, {151}, {152}, {157}, {169}, 
		{172}, {179}, {190}, {191}, {192}, {193}, {194}, {195}, {196}, {197}, {198}, {199}, {201}, {205}, {207}, {211}, {214}, {215}, {216}, 
		{218}, {219}, {224}, {225}, {226}, {231}, {232}, {233}, {237}, {238}, {243}, {244}, {245}, {246}, {251}, {256}, {257}, {263}, {306}, 
		{307}, {308}, {309}
	};
	for(new i; i < sizeof(female_skin); i++)
	{
		if(skin == female_skin[i][0]) return 1;
	}
	return 0;
}

stock LoadAccounts(playerid)
{
	static const sql_load[] = "SELECT * FROM Accounts WHERE Name = '%s'";
	array:string[sizeof(sql_load) - 2 + MAX_PLAYER_NAME + 1];
	format(string, sizeof(string), sql_load, PlayerInfo[playerid][Name]);
	mysql_function_query(server_database, string, true, !"LoadPlayerAccounts", "i", playerid);
}

stock SavePlayer(playerid)
{
	static const update[] = "UPDATE `Accounts` SET `Health` = '%f' WHERE `Name` = '%s'";
	array:string[sizeof(update) + (- 2 + MAX_PLAYER_NAME) + (- 2 + 9) + 1];
	format(string, sizeof(string), update, PlayerInfo[playerid][Health], PlayerInfo[playerid][Name]);
	mysql_function_query(server_database, string, false, "", "");
}

stock SetPlayerMoney(playerid, money)
{
	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, money);
	static const update[] = "UPDATE `Accounts` SET `Money` = '%i' WHERE `Name` = '%s'";
	array:string[sizeof(update) + (- 2 + MAX_PLAYER_NAME) + (- 2 + 9) + 1];
	format(string, sizeof(string), update, PlayerInfo[playerid][Money], PlayerInfo[playerid][Name]);
	mysql_function_query(server_database, string, false, "", "");
}

stock SendAdminMessage(color, text[], level = 1)
{
	foreach(new i: Player)
	{
		if(0 == IsPlayerConnected(i)) continue;
		if(false == player_logged[i]) continue;
		if(PlayerInfo[i][Admin] < level) continue;
		SendClientMessage(i, color, text);
	}
}

stock ResetPlayerInfo(playerid)
{
	SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL, 0);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SAWNOFF_SHOTGUN, 0);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SPAS12_SHOTGUN, 0);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_MICRO_UZI, 0);
	SetPlayerColor(playerid, 0xFFFFFF33);
	SetPlayerHealth(playerid, 100.00);
	ResetPlayerMoney(playerid);
	//ResetPlayerWeapons(playerid);
	player_logged[playerid] = false;
	for(new i; i < sizeof(server_skin_show); i ++)  
		TextDrawHideForPlayer(playerid, server_skin_show[i]);
	CancelSelectTextDraw(playerid);
	strmid(PlayerInfo[playerid][Name], "", 0, strlen(""), MAX_PLAYER_NAME);
	strmid(PlayerInfo[playerid][Password], "", 0, strlen(""), MAX_PLAYER_NAME);
	strmid(PlayerInfo[playerid][IP], "", 0, strlen(""), MAX_PLAYER_NAME);
	eat_player[playerid] = 0;
	PlayerInfo[playerid][Money] = 0;
	PlayerInfo[playerid][Skin] = 0;
	PlayerInfo[playerid][Sex] = 0;
	PlayerInfo[playerid][Admin] = 0;
	PlayerInfo[playerid][Level] = 0;
	PlayerInfo[playerid][Exp] = 0;
	LoadPlayerAnim(playerid);
	for(new i = 0; i <= 10; i ++) 
		SetPlayerAttachedObject(playerid, i, 2355, 1, 0.11, 0.334523, -0.267872, 109.200798, 116.924514, 310.923736, 1.025472, 1.000000, 1.000000);
	for(new i = 0; i <= 10; i ++) 
		RemovePlayerAttachedObject(playerid, i);
	player_actor_skin_id[playerid] = 0;
	job_building[playerid] = 0;
	job_building_money[playerid] = 0;
	job_building_bag[playerid] = 0;
	job_plant[playerid] = 0;
	job_plant_money[playerid] = 0;
	job_plant_metal[playerid] = false;
}

stock GiveEat(playerid)
{
	if(eat_player[playerid] >= 1)
		return SendClientMessage(playerid, GRAY, !"У вас уже есть поднос с едой");
	for(new i = 1; i < MAX_TRAYS_EAT; i ++)
	{
		if(eat[i][eat_status] == 0)
		{
			printf("Выдан поднос с ID: %i", i);
			ApplyAnimation(playerid, !"CARRY", !"crry_prtial", 4.0, 1, 0, 0, 1, 1, 1);
			SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
			static const status[] = "%s взял поднос с бесплатной едой";
			new string[sizeof(status) + 1 + (- 2 + MAX_PLAYER_NAME)];
			format(string, sizeof(string), status, PlayerInfo[playerid][Name]);
			StatusMessage(playerid, string, !"взял поднос с бесплатной едой");
			SendClientMessage(playerid, WHITE, !"Воспользуйтесь командой {33FF00}/eat{ffffff} для употребления пищи либо {33FF00}/put{ffffff}, что бы положить поднос");
			SetPlayerAttachedObject(playerid, 0, 2355, 1, 0.11, 0.334523, -0.267872, 109.200798, 116.924514, 310.923736, 1.025472, 1.000000, 1.000000);
			eat[i][eat_status] = 1;
			eat_player[playerid] = i;
			break;
		}
	}
	if(eat_player[playerid] == 0)
		return SendClientMessage(playerid, WHITE, !"Извините, но в данный момент пункт раздачи бесплатной пищи закрыт на перерыв.Приходи позже");
	return true;
}

stock DropEat(playerid, type = 0)
{
	if(type == 0)
	{
		SendClientMessage(playerid, GRAY, !"Вы уронили поднос с едой");
		ClearPlayerAnim(playerid);
	}
	RemovePlayerAttachedObject(playerid, 0);
	
	new 
		Float: player_pos_x, 
		Float: player_pos_y, 
		Float: player_pos_z;
	
	new 
		plaeyr_eat_id = eat_player[playerid];
	printf("Уронили поднос с ID: %i", plaeyr_eat_id);			
	GetPlayerPos(playerid, player_pos_x, player_pos_y, player_pos_z);
	GetPlayerFacingAngle(playerid, eat[plaeyr_eat_id][eat_angle]);
	player_pos_x = player_pos_x + (0.8 * floatsin(- eat[plaeyr_eat_id][eat_angle], degrees));
    player_pos_y = player_pos_y + (0.8 * floatcos(- eat[plaeyr_eat_id][eat_angle], degrees));
	eat[plaeyr_eat_id][eat_x] = player_pos_x;
	eat[plaeyr_eat_id][eat_y] = player_pos_y;
	eat[plaeyr_eat_id][eat_z] = player_pos_z;
	eat[plaeyr_eat_id][eat_virtualworld] = GetPlayerVirtualWorld(playerid);
	eat[plaeyr_eat_id][eat_interior] = GetPlayerInterior(playerid);
	eat[plaeyr_eat_id][eat_angle] = eat[plaeyr_eat_id][eat_angle] + (90) + (0.8 * floatcos(- eat[plaeyr_eat_id][eat_angle], degrees));
	eat[plaeyr_eat_id][eat_status] = 2;
	eat[plaeyr_eat_id][eat_time_drop] =  gettime();
	eat[plaeyr_eat_id][eat_id] = CreateDynamicObject(2355, eat[plaeyr_eat_id][eat_x], eat[plaeyr_eat_id][eat_y], eat[plaeyr_eat_id][eat_z] - 0.9, -25.400, 23.300, eat[plaeyr_eat_id][eat_angle], eat[plaeyr_eat_id][eat_virtualworld], eat[plaeyr_eat_id][eat_interior], -1, 30.00, 30.00);
	eat[plaeyr_eat_id][eat_text] = CreateDynamic3DTextLabel(!"Используйте {1e88e5}/pick\n{ffffff}что бы поднять поднос с едой", WHITE, eat[plaeyr_eat_id][eat_x], eat[plaeyr_eat_id][eat_y], eat[plaeyr_eat_id][eat_z] - 0.6, 3.00, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, eat[plaeyr_eat_id][eat_virtualworld], eat[plaeyr_eat_id][eat_interior], -1, 3.00);
	eat_player[playerid] = 0;
}

stock ClearPlayerAnim(playerid)
{
    ApplyAnimation(playerid, !"ped", !"facsurp", 4.0, 1, 0, 0, 1, 1, 1);
    ApplyAnimation(playerid, !"ped", !"facsurp", 4.0, 1, 0, 0, 1, 1, 1);
    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
    return true;
}

stock LoadPlayerAnim(playerid)
{
	ApplyAnimation(playerid, !"CARRY", !"null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, !"FOOD", !"null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, !"OTB", !"null", 0.0, 0, 0, 0, 0, 0);
	return true;
}

stock StatusMessage(playerid, str[], textbuble[])
{
	new Float: Posw[3];
	GetPlayerPos(playerid, Posw[0], Posw[1], Posw[2]);
	foreach(new i: Player)
	{
		if(!IsPlayerInRangeOfPoint(i, 15.0, Posw[0], Posw[1], Posw[2]) || !IsPlayerConnected(i)) continue;
		if(GetPlayerInterior(playerid) != GetPlayerInterior(i) || GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(i)) continue;
		SendClientMessage(i, 0xdd90ffAA, str);
		SetPlayerChatBubble(playerid, textbuble, 0xdd90ffFF, 15.0, 3000);
	}
	return true;
}

CMD:ahelp(playerid, params[])
{
	new level = PlayerInfo[playerid][Admin];
	if(0 == level)
		return 1;
	if(level >= 1)
		SendClientMessage(playerid, GREEN, !"Доступные команды"), SendClientMessage(playerid, YELLOW, !"1 уровень: /ans /a /admins /sp /stats /weap /setting /money /tp");
	if(level >= 2)
		SendClientMessage(playerid, YELLOW, !"2 уровень: /mute /unmute /kick /hp /hpveh /setfuel /house /biz /get");
	if(level >= 3)
		SendClientMessage(playerid, YELLOW, !"3 уровень: /jail /unjail /ban /warn /skick /getip /goto /respv /hpall");
	if(level >= 4)
		SendClientMessage(playerid, YELLOW, !"4 уровень: /unban /unwarn /veh /delveh /templeader /msg /gethere /ears");
	if(level >= 5)
		SendClientMessage(playerid, YELLOW, !"5 уровень: /weather /banip /unbanip /skin /showip /сad /resetgun /uval");
	return 1;
}

CMD:ans(playerid, params[])
{
	if(0 == PlayerInfo[playerid][Admin])
		return 1;
	new 
		source, text[71];
	if(sscanf(params, !"us[70]", source, text))
		return SendClientMessage(playerid, GRAY, !"Используйте {33FF00}/ans [ID Игрока] [Сообщение]");
	static const
		player_message[] = "Администратор %s для игрока %s: %s",
		admin_message[] = "[A] Администратор %s[%i] для игрока %s[%i]: %s";
	const
		admin_size = sizeof(admin_message) + 
			(( - 2 + MAX_PLAYER_NAME) * 2) + 
			((- 2 + 3) * 2) + 70;
	new 
		string[admin_size];
	format(string, sizeof(string), admin_message, PlayerInfo[playerid][Name], playerid, PlayerInfo[source][Name], source, text);
	SendAdminMessage(0xFF9933FF, string);
	format(string, sizeof(string), player_message, PlayerInfo[playerid][Name], PlayerInfo[source][Name], text);
	SendClientMessage(source, 0xFF9933FF, string);
	return 1;
}

CMD:a(playerid, params[])
{
	if(0 == PlayerInfo[playerid][Admin])
		return 1;
	new 
		text[115];
	if(sscanf(params, !"s[114]", text))
		return SendClientMessage(playerid, GRAY, !"Используйте {33FF00}/a [Сообщение]");
	static const
		message[] = "[A] %s[%i]: %s";
	new 
		string[sizeof(message) +
			(- 2 + MAX_PLAYER_NAME) + 
			(- 2 + 3) + 
			(- 2 + 114)];
	format(string, sizeof(string), message, PlayerInfo[playerid][Name], playerid, text);
	SendAdminMessage(BLUE, string);
	return 1;
}

CMD:admins(playerid, params[])
{
	if(0 == PlayerInfo[playerid][Admin])
		return 1;
	static const 
		message[] = "%s[%i] (%i уровень)";
	new 
		string[sizeof(message) + 
			(- 2 + MAX_PLAYER_NAME) + 
			(- 2 + 3) + 
			(- 2 + 1) + 
			(- 2 + 16) + 1];
	SendClientMessage(playerid, 0x33FF00FF, !"Администраторы в сети:");
	foreach(new i: Player)
	{
		if(0 == IsPlayerConnected(i)) continue;
		if(false == player_logged[i]) continue;
		if(PlayerInfo[i][Admin] >= 1 && PlayerInfo[i][Admin] <= 5)
		{
			format(string, sizeof(string), message, PlayerInfo[i][Name], i, PlayerInfo[i][Admin]);
		}
		if(PlayerInfo[i][Admin] == 6)
		{
			strcat(string, !"Главный администратор");
		}
		if(PlayerInfo[i][Admin] == 7)
		{
			strcat(string, !"Forest Team / {CC0000}One of the developers");
		}
		SendClientMessage(i, YELLOW, string);
	}
	return 1;
}

CMD:eat(playerid, params[])
{
	if(eat_player[playerid] == 0)
		return SendClientMessage(playerid, GRAY, !"У вас нет подноса с едой");
	new hour, action[11];
    gettime(hour, _, _);
    switch(hour)
    {
        case 7..12: 	strcat(action, "завтракает");
        case 13..17: 	strcat(action, "обедает");
        case 18..23: 	strcat(action, "ужинает");
        default: 		strcat(action, "ест");
    }
	static const status[] = "%s %s";
	array:string[sizeof(status) + 1 + (- 2 + MAX_PLAYER_NAME) + (- 2 + sizeof(action))];
	format(string, sizeof(string), status, PlayerInfo[playerid][Name], action);
	StatusMessage(playerid, string, action);
	ClearPlayerAnim(playerid);
	ApplyAnimation(playerid, !"FOOD", !"EAT_Burger", 4.0, 0, 0, 0, 0, 0, 1);
	eat_player[playerid] = 0;
	RemovePlayerAttachedObject(playerid, 0);
	SetPlayerHealth(playerid, PlayerInfo[playerid][Health] + (random(15) + 10));
	return true;
}

CMD:put(playerid)
{
	if(eat_player[playerid] == 0)
		return SendClientMessage(playerid, GRAY, !"У вас нет подноса с едой");
	ClearPlayerAnim(playerid);
	ApplyAnimation(playerid, !"CARRY", !"putdwn", 4.1, 0, 0, 0, 0, 0, 0);
	DropEat(playerid, 1);
	SetTimerEx(!"@Update", 1200, false, "i", playerid);
	return true;
}

CMD:pick(playerid, params[])
{
	if(eat_player[playerid] == 1)
		return SendClientMessage(playerid, GRAY, !"У вас уже есть поднос с едой");
	for(new i = 1; i < MAX_TRAYS_EAT; i ++)
	{
		if(IsPlayerInRangeOfPoint(playerid, 0.7, eat[i][eat_x], eat[i][eat_y], eat[i][eat_z]))
		{
			printf("Выдан поднос с ID: %i", i);
			ClearPlayerAnim(playerid);
			ApplyAnimation(playerid, !"CARRY", !"liftup", 4.1, 0, 0, 0, 0, 0, 0);
			eat_player[playerid] = i;
			
			//ApplyAnimation(playerid, !"CARRY", !"crry_prtial", 4.0, 1, 0, 0, 1, 1, 1);
			///SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
			//static const status[] = "%s взял поднос с бесплатной едой";
			//new string[sizeof(status) + 1 + (- 2 + MAX_PLAYER_NAME)];
			//format(string, sizeof(string), status, PlayerInfo[playerid][Name]);
			//StatusMessage(playerid, string, !"взял поднос с бесплатной едой");
			SendClientMessage(playerid, WHITE, !"Воспользуйтесь командой {33FF00}/eat{ffffff} для употребления пищи либо {33FF00}/put{ffffff}, что бы положить поднос");
			eat[i][eat_status] = 1;
			DestroyDynamicObject(eat[i][eat_id]);
			DestroyDynamic3DTextLabel(eat[i][eat_text]);
			SetTimerEx(!"@GiveEat", 1200, false, "i", playerid);
		}
	}
	if(eat_player[playerid] == 0)
		return SendClientMessage(playerid, GRAY, !"Рядом с вами нет подносов с едой");
	return true;
}

CMD:mn(playerid, params[])
{
	ShowPlayerDialog(playerid, 999, DIALOG_STYLE_LIST, !"{1976D2}Главное меню", 
		!"1. Cтатистика персонажа\n\
		 2. Список команд\n\
		 3. Личные настройки\n\
		 4. Связь с администрацией\n\
		 5. Изменение имени\n\
		 6. Правила сервера\n\
		 7. Настройки безопасности\n\
		 8. Дополнительно", !"Далее", !"Закрыть");
	return true;
}

CMD:flycam(playerid, params[])
{
	if(0 == PlayerInfo[playerid][Admin])
		return 1;
	new 
		type;
	if(sscanf(params, !"i", type))
		return SendClientMessage(playerid, GRAY, !"Используйте {33FF00}/flycam [Тип]");
	SetPlayerCamera(playerid, type);
	return 1;
}

CMD:flycamspeed(playerid, params[])
{
	if(0 == PlayerInfo[playerid][Admin])
		return 1;
	new 
		Float: speed;
	if(sscanf(params, !"f", speed))
		return SendClientMessage(playerid, GRAY, !"Используйте {flycamspeed}/flycam [Скорость]");
	SetPlayerCameraSpeed(playerid, speed);
	return 1;
}

CMD:gethere(playerid, params[])
{
	if(0 == PlayerInfo[playerid][Admin])
		return 1;
	new 
		type;
	if(sscanf(params, !"i", type))
		return SendClientMessage(playerid, GRAY, !"Используйте {33FF00}/gethere [ID Игрока]");
	new Float:plocx,Float:plocy,Float:plocz;
	GetPlayerPos(playerid, plocx, plocy, plocz);
	SetPlayerPos(type,plocx,plocy+2, plocz);
	return 1;
}

CMD:veh(playerid, params[])
{	
	if(sscanf(params, !"dD(0)D(0)", params[0], params[1], params[2]))
		return SendClientMessage(playerid, GRAY, !"Используйте: /veh [ID Автомобиля] [Первый цвет] [Второй цвет]");
    new Float:X,Float:Y,Float:Z;
	GetPlayerPos(playerid, X,Y,Z);
	CreateVehicle(params[0], X, Y + 2, Z, 0.0, params[1], params[2], 60000);
	return true;
}

CMD:setweather(playerid, params[])
{
	if(sscanf(params, !"d", params[0]))
		return SendClientMessage(playerid, GRAY, !"Используйте: /setweather [ID Погоды]");
	SetWeather(params[0]);
	return true;
}

CMD:settime(playerid, params[])
{
	if(sscanf(params, !"d", params[0]))
		return SendClientMessage(playerid, GRAY, !"Используйте: /settime [Время]");
	SetWorldTime(params[0]);
	return true;
}

CMD:skin(playerid, params[])
{
	if(sscanf(params, !"dd", params[0], params[1]))
		return SendClientMessage(playerid, GRAY, !"Используйте: /skin [ID Автомобиля] [ID Скина]");
    SetPlayerSkin(params[0], params[1]);
	return true;
}

CMD:givegun(playerid, params[])
{	
	if(sscanf(params, !"ddd", params[0], params[1], params[2]))
		return true;
    GivePlayerWeapon(params[0], params[1], params[2]);
	return true;
}

CMD:plant(playerid, params[])
{	
	SetPlayerPos(playerid, 30.5390, 0.3367, 1001.6033); 
	SetPlayerFacingAngle(playerid, 178.2332);
	SetPlayerVirtualWorld(playerid, 3);
	SetPlayerInterior(playerid, 3);
	SetCameraBehindPlayer(playerid);
	return true;
}

CMD:buyfuel(playerid, params[])
{
	new 
		vehicle = GetPlayerVehicleID(playerid),
		trailer = GetVehicleTrailer(vehicle),
		temp = 0;
	if(!IsPlayerInAnyVehicle(playerid) || vehicle < TankInfo[0][tank_id] && vehicle > TankInfo[3][tank_id])
		return SendClientMessage(playerid, GRAY, !"Вы должны находиться на нефтеперерабатывающем заводе, в служебном транспорте");
	new buy_fuel;
	if(sscanf(params, "i", buy_fuel))
		return SendClientMessage(playerid, GRAY, !"Используйте {33FF00}/buyfuel [Кол-во литров]");
	if(buy_fuel <= 0 || buy_fuel > 5000)
		return SendClientMessage(playerid, GRAY, !"Количество литров для заливки в цистерну должно быть в диапазоне от {33FF00}1{ffffff} до {33FF00}5000");
	if(!IsPlayerInDynamicArea(playerid, plant_tank_cude))
		return SendClientMessage(playerid, GRAY, !"Вы должны находиться на нефтеперерабатывающем заводе");
	else
	{
		if(TankInfo[trailer - 1][tank_fuel] + buy_fuel > 5000)
				return SendClientMessage(playerid, GRAY, !"В цестерне не достаточно места");
		if(IsPlayerInRangeOfPoint(playerid, 3, 217.9251, 1371.3468, 11.0226))
		{
			if(tank[0] < tank[0] - buy_fuel)
				return SendClientMessage(playerid, GRAY, !"В цистерне завода не достаточно топлива");
			tank[0] = tank[0] - buy_fuel;
			temp = 1;
		}
		else if(IsPlayerInRangeOfPoint(playerid, 3, 218.0482, 1395.9663, 11.0226))
		{
			if(tank[1] < tank[1] - buy_fuel)
				return SendClientMessage(playerid, GRAY, !"В цистерне завода не достаточно топлива");
			tank[1] = tank[1] - buy_fuel;
			temp = 1;
		}
		else if(IsPlayerInRangeOfPoint(playerid, 3, 218.1711, 1420.5713, 11.0226))
		{
			if(tank[2] < tank[2] - buy_fuel)
				return SendClientMessage(playerid, GRAY, !"В цистерне завода не достаточно топлива");
			tank[2] = tank[2] - buy_fuel;
			temp = 1;
		}
		else if(IsPlayerInRangeOfPoint(playerid, 3, 218.2956, 1445.4922, 11.0226))
		{
			if(tank[3] < tank[3] - buy_fuel)
				return SendClientMessage(playerid, GRAY, !"В цистерне завода не достаточно топлива");
			tank[3] = tank[3] - buy_fuel;
			temp = 1;
		}
	}
	if(temp == 0)
		return SendClientMessage(playerid, GRAY, !"Подъедьте к одной из цистерн");
	UpdateRefinery();
	static const tank_info[] = "Цистерна\nЗалито {33FF00}%i{ffffff}/{33FF00}5000{ffffff} литров топлива";
	array:string[sizeof(tank_info) - 2 + 5 ];
	for(new i = 0; i <= 6; i ++)
	{
		if(vehicle == i)
		{
			TankInfo[trailer - 1][tank_fuel] = TankInfo[trailer - 1][tank_fuel] + buy_fuel;
			format(string, sizeof(string), tank_info, TankInfo[trailer - 1][tank_fuel]);
			switch(trailer)
			{
				case 4: UpdateDynamic3DTextLabelText(text_car_plant[0], WHITE, string);
				case 5: UpdateDynamic3DTextLabelText(text_car_plant[1], WHITE, string);
				case 6: UpdateDynamic3DTextLabelText(text_car_plant[2], WHITE, string);
			}
		
		}
	}
	static const info[] = "Вы загрузили в цистерну бензавоза {33FF00}%i{ffffff} литров топлива";
	format(string, sizeof(string), info, buy_fuel);
	SendClientMessage(playerid, WHITE, string);
	return true;
}

CMD:sellfuel(playerid, params[])
{
	new 
		vehicle = GetPlayerVehicleID(playerid),
		trailer = GetVehicleTrailer(vehicle);
	if(!IsPlayerInAnyVehicle(playerid) || vehicle < TankInfo[0][tank_id] && vehicle > TankInfo[3][tank_id])
		return SendClientMessage(playerid, GRAY, !"Вы должны находиться на заводе по производству оружейных заготовок, в служебном транспорте");
	new sell_fuel;
	if(sscanf(params, "i", sell_fuel))
		return SendClientMessage(playerid, GRAY, !"Используйте {33FF00}/sellfuel [Кол-во литров]");
	if(TankInfo[trailer - 1][tank_fuel] - sell_fuel < 0)
		return SendClientMessage(playerid, GRAY, !"В цестерне нет столько топлива");
	if(IsPlayerInRangeOfPoint(playerid, 5, -19.3325, -277.6135, 5.4297))
	{
		if(plant_fuel + sell_fuel > 250000)
			return SendClientMessage(playerid, GRAY, !"Склад завода не может вместить в себя столько топлива");
		plant_fuel = plant_fuel + sell_fuel;
	}
	else
		return SendClientMessage(playerid, GRAY, !"Вы должны находиться на заводе по производству оружейных заготовок");
	UpdatePlantStore();
	static const tank_info[] = "Цистерна\nЗалито {33FF00}%i{ffffff}/{33FF00}5000{ffffff} литров топлива";
	array:string[sizeof(tank_info) + 1];
	for(new i = 0; i <= 6; i ++)
	{
		if(vehicle == i)
		{
			TankInfo[trailer - 1][tank_fuel] = TankInfo[trailer - 1][tank_fuel] - sell_fuel;
			format(string, sizeof(string), tank_info, TankInfo[trailer - 1][tank_fuel]);
			switch(trailer)
			{
				case 4: UpdateDynamic3DTextLabelText(text_car_plant[0], WHITE, string);
				case 5: UpdateDynamic3DTextLabelText(text_car_plant[1], WHITE, string);
				case 6: UpdateDynamic3DTextLabelText(text_car_plant[2], WHITE, string);
			}
		
		}
	}
	//static const info[] = "Вы загрузили в цистерну бензавоза {33FF00}%i{ffffff} литров топлива";
	//format(string, sizeof(string), info, buy_fuel);
	//SendClientMessage(playerid, WHITE, string);
	return true;
}