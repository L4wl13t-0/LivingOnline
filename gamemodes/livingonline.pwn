//****************************Living Online Roleplay****************************
/*
||===============================================||
|| Nombre: Living Online Roleplay                ||
|| Programador: STMSTUDIO                        ||
|| Mapper: STMSTUDIO                             ||
|| Versión: 0.1 Oficial                          ||
||===============================================||
*/

#include <a_samp>
#include <core>
#include <float>
#include <YSI\y_ini>

#pragma 				tabsize 					(0)

//Sistema de registro
#define 				RegisterDialog 				(1)
#define 				LoginDialog 				(2)
#define					RegisterSex					(3)
#define					RegisterAge					(4)
#define 				SuccessRegister 			(5)
#define 				SuccessLogin 				(6)

#define 				User_Path					"/Users/%s.ini"

//Colores
#define					COLOR_WHITE_T				"{FFFFFF}"
#define					COLOR_RED_T					"{F81414}"
#define					COLOR_GREEN_T				"{00FF22}"
#define					COLOR_BLACK					0x000000FF
#define					COLOR_WHITE					0xFFFFFFAA
#define					COLOR_YELLOW				0xE6E915FF
#define					COLOR_RED 					0xE60000FF

//------------------Limites-----------------------------
#define					MAX_PING					(1500)

//-------------------------------------------------------

//enum sistema de registro
enum PlayerData
{
	Pass,
	Money,
	Float:Health,
	Float:Armour,
	Sex,
	Age,
	VIP,
	Admin,
	Float:PosX,
	Float:PosY,
	Float:PosZ,
	Skin,
	VirtualW,
	Interior
};
new pInfo[MAX_PLAYERS][PlayerData];

//Funcion para cargar los datos del usuario
forward LoadUser_data(playerid, name[], value[]);
public LoadUser_data(playerid, name[], value[])
{
    INI_Int("Password", pInfo[playerid][Pass]);
	INI_Int("Money", pInfo[playerid][Money]);
	INI_Float("Health", pInfo[playerid][Health]);
	INI_Float("Armour", pInfo[playerid][Armour]);
	INI_Int("Sex", pInfo[playerid][Sex]);
	INI_Int("Age", pInfo[playerid][Age]);
	INI_Int("VIP", pInfo[playerid][VIP]);
	INI_Int("Admin", pInfo[playerid][Admin]);
	INI_Float("PosX", pInfo[playerid][PosX]);
	INI_Float("PosY", pInfo[playerid][PosY]);
	INI_Float("PosZ", pInfo[playerid][PosZ]);
	INI_Int("Skin", pInfo[playerid][Skin]);
	INI_Int("VirtualW", pInfo[playerid][VirtualW]);
	INI_Int("Interior", pInfo[playerid][Interior]);

    return 1;
}
stock UserPath(playerid)
{
    new string[128], playername[MAX_PLAYER_NAME];
    GetPlayerName(playerid, playername, sizeof(playername));
    format(string, sizeof(string), User_Path, playername);
    return string;
}
stock udb_hash(buf[])
{
    new length = strlen(buf);
    new s1 = 1;
    new s2 = 0;
    new n;
    for (n=0; n<length; n++)
    {
       s1 = (s1 + buf[n]) % 65521;
       s2 = (s2 + s1)     % 65521;
    }
    return (s2 << 16) + s1;
}

main()
{
	print("\n---------------------------------------");
	print("Iniciando Living Online Roleplay\n");
	print("---------------------------------------\n");
}

//----------------------------------------------------------

public OnPlayerConnect(playerid)
{
	if(fexist(UserPath(playerid)))
	{
		INI_ParseFile(UserPath(playerid), "LoadUser_%s", .bExtra = true, .extra = playerid);
		ShowPlayerDialog(playerid, LoginDialog, DIALOG_STYLE_INPUT, ""COLOR_WHITE_T"Iniciar sesion", ""COLOR_WHITE_T"Ingresa tu contraseña para iniciar sesion:", "Ingresar", "Salir");
	}
	else
	{
		ShowPlayerDialog(playerid, RegisterDialog, DIALOG_STYLE_INPUT, ""COLOR_WHITE_T"Registrarse", ""COLOR_WHITE_T"Escribe una contraseña para crear tu cuenta:", "Siguiente", "Salir");
	}

 	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	GetPlayerHealth(playerid, pInfo[playerid][Health]);
	GetPlayerArmour(playerid, pInfo[playerid][Armour]);
	pInfo[playerid][Money] = GetPlayerMoney(playerid);
	GetPlayerPos(playerid, pInfo[playerid][PosX], pInfo[playerid][PosY], pInfo[playerid][PosZ]);
	pInfo[playerid][VirtualW] = GetPlayerVirtualWorld(playerid);
	pInfo[playerid][Interior] = GetPlayerInterior(playerid);
	pInfo[playerid][Skin] = GetPlayerSkin(playerid);

	new INI:File = INI_Open(UserPath(playerid));
	INI_SetTag(File, "data");
	INI_WriteInt(File, "Money", pInfo[playerid][Money]);
	INI_WriteFloat(File, "Health", pInfo[playerid][Health]);
	INI_WriteFloat(File, "Armour", pInfo[playerid][Armour]);
	INI_WriteInt(File, "Sex", pInfo[playerid][Sex]);
	INI_WriteInt(File, "Age", pInfo[playerid][Age]);
	INI_WriteInt(File, "VIP", pInfo[playerid][VIP]);
	INI_WriteInt(File, "Admin", pInfo[playerid][Admin]);
	INI_WriteFloat(File, "PosX", pInfo[playerid][PosX]);
	INI_WriteFloat(File, "PosY", pInfo[playerid][PosY]);
	INI_WriteFloat(File, "PosZ", pInfo[playerid][PosZ]);
	INI_WriteInt(File, "Skin", pInfo[playerid][Skin]);
	INI_WriteInt(File, "VirtualW", pInfo[playerid][VirtualW]);
	INI_WriteInt(File, "Interior", pInfo[playerid][Interior]);
	INI_Close(File);

	return 1;
}

//----------------------------------------------------------

public OnPlayerSpawn(playerid)
{
	return 1;
}

//----------------------------------------------------------

public OnPlayerDeath(playerid, killerid, reason)
{
   	return 1;
}

//----------------------------------------------------------

public OnGameModeInit()
{
	SetGameModeText("Living Online Roleplay");
	ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
	ShowNameTags(0);
	SetNameTagDrawDistance(7.0);
	EnableStuntBonusForAll(0);
	DisableInteriorEnterExits();
	SetWeather(2);
	SetWorldTime(11);
	
	return 1;
}

//----------------------------------------------------------

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case RegisterDialog:
		{
			if(!response) return Kick(playerid);
			if(response)
			{
            	if(!strlen(inputtext)) return ShowPlayerDialog(playerid, RegisterDialog, DIALOG_STYLE_INPUT, ""COLOR_WHITE_T"Registro",""COLOR_RED_T"Has ingresado una contraseña inválida.\n"COLOR_WHITE_T"Escribe una contraseña valida para registrarse:","Siguiente","Salir");
				new INI:File = INI_Open(UserPath(playerid));
				INI_SetTag(File, "data");
				INI_WriteInt(File, "Password", udb_hash(inputtext));
				INI_WriteInt(File, "Money", 0);
				INI_WriteFloat(File, "Health", 0);
				INI_WriteFloat(File, "Armour", 0);
				INI_WriteInt(File, "VIP", 0);
				INI_WriteInt(File, "Admin", 0);
				INI_WriteFloat(File, "PosX", 0);
				INI_WriteFloat(File, "PosY", 0);
				INI_WriteFloat(File, "PosZ", 0);
				INI_WriteInt(File, "Skin", 277);
				INI_WriteInt(File, "VirtualW", 0);
				INI_WriteInt(File, "Interior", 0);
				INI_Close(File);

				ShowPlayerDialog(playerid, RegisterAge, DIALOG_STYLE_INPUT, ""COLOR_WHITE_T"Edad",""COLOR_WHITE_T"Ahora necesitamos que nos digas tu edad:", "Siguiente", "Cancelar");

				return 1;
			}
		}
		case LoginDialog:
		{
			if(!response) return Kick(playerid);
			if(response)
			{
				if(udb_hash(inputtext) == pInfo[playerid][Pass])
				{
					INI_ParseFile(UserPath(playerid), "LoadUser_%s", .bExtra = true, .extra = playerid);
					GivePlayerMoney(playerid, pInfo[playerid][Money]);
					SetPlayerHealth(playerid, pInfo[playerid][Health]);
					SetPlayerArmour(playerid, pInfo[playerid][Armour]);
					SetPlayerVirtualWorld(playerid, pInfo[playerid][VirtualW]);
					SetPlayerInterior(playerid, pInfo[playerid][Interior]);
					ShowPlayerDialog(playerid, SuccessLogin, DIALOG_STYLE_MSGBOX, ""COLOR_WHITE_T"¡Listo!", ""COLOR_GREEN_T"Has iniciado sesion correctamente.", "Entendido", "");
					SetSpawnInfo(playerid, 0, pInfo[playerid][Skin], pInfo[playerid][PosX], pInfo[playerid][PosY], pInfo[playerid][PosZ], 1.0, 0, 0, 0, 0, 0, 0);
					SpawnPlayer(playerid);
				}
				else
				{
					ShowPlayerDialog(playerid, LoginDialog, DIALOG_STYLE_INPUT, ""COLOR_WHITE_T"Ingreso", ""COLOR_RED_T"Colocaste una contraseña incorrecta.\nEscribe tu contraseña para ingresar:", "Ingresar", "Salir");
				}
				return 1;
			}
		}
		case RegisterAge:
		{
			if(!response) return Kick(playerid);
			if(response)
			{
				if(strval(inputtext) < 15 || strval(inputtext) > 99) return ShowPlayerDialog(playerid, RegisterAge, DIALOG_STYLE_INPUT, ""COLOR_WHITE_T"Edad",""COLOR_RED_T"Ingresaste una edad no permitida, debe ser mayor que 15 y menor de 99:", "Siguiente", "Cancelar");

				pInfo[playerid][Age] = strval(inputtext);
				ShowPlayerDialog(playerid, RegisterSex, DIALOG_STYLE_MSGBOX, ""COLOR_WHITE_T"Sexo",""COLOR_WHITE_T"Ahora necesitamos que nos digas tu genero:", "Hombre", "Mujer");
			}
		}
		case RegisterSex:
		{
			if(response == 1)
			{
				pInfo[playerid][Sex] = 1;

				SetSpawnInfo(playerid, 0, 60, -2016.4399, -79.7714, 35.3203, 0, 0, 0, 0, 0, 0, 0);
				SetPlayerVirtualWorld(playerid, 0);
				SetPlayerInterior(playerid, 0);
				SetPlayerSkin(playerid, 60);
				GivePlayerMoney(playerid, 15000);
				SpawnPlayer(playerid);
			}
			else
			{
				pInfo[playerid][Sex] = 2;

				SetSpawnInfo(playerid, 0, 56, -2016.4399, -79.7714, 35.3203, 0, 0, 0, 0, 0, 0, 0);
				SetPlayerVirtualWorld(playerid, 0);
				SetPlayerInterior(playerid, 0);
				SetPlayerSkin(playerid, 56);
				GivePlayerMoney(playerid, 15000);
				SpawnPlayer(playerid);
			}
		}
	}
	return 1;
}

/*
||===============================================||
|| Nombre: Living Online Roleplay                ||
|| Programador: STMSTUDIO                        ||
|| Mapper: STMSTUDIO                             ||
|| Versión: 0.1 Oficial                          ||
||===============================================||
*/
//****************************Living Online Roleplay****************************