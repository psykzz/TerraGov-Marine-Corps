#define JOB_DISPLAY_ORDER_DEFAULT 0

#define JOB_DISPLAY_ORDER_CAPTAIN 				1
#define JOB_DISPLAY_ORDER_EXECUTIVE_OFFICER 	2
#define JOB_DISPLAY_ORDER_STAFF_OFFICER 		3
#define JOB_DISPLAY_ORDER_PILOT_OFFICER 		4
#define JOB_DISPLAY_ORDER_TANK_CREWMAN 			5
#define JOB_DISPLAY_ORDER_CORPORATE_LIAISON 	6
#define JOB_DISPLAY_ORDER_SYNTHETIC 			7
#define JOB_DISPLAY_ORDER_AI 					8
#define JOB_DISPLAY_ORDER_CHIEF_MP 				9
#define JOB_DISPLAY_ORDER_MILITARY_POLICE 		10
#define JOB_DISPLAY_ORDER_CHIEF_ENGINEER 		11
#define JOB_DISPLAY_ORDER_SHIP_TECH     		12
#define JOB_DISPLAY_ORDER_REQUISITIONS_OFFICER 	13
#define JOB_DISPLAY_ORDER_CHIEF_MEDICAL_OFFICER 15
#define JOB_DISPLAY_ORDER_DOCTOR 				16
#define JOB_DISPLAY_ORDER_MEDIAL_RESEARCHER 	17
#define JOB_DISPLAY_ORDER_SQUAD_LEADER 			18
#define JOB_DISPLAY_ORDER_SQUAD_SPECIALIST 		19
#define JOB_DISPLAY_ORDER_SQUAD_SMARTGUNNER 	20
#define JOB_DISPLAY_ORDER_SQUAD_CORPSMAN 		21
#define JOB_DISPLAY_ORDER_SUQAD_ENGINEER 		22
#define JOB_DISPLAY_ORDER_SQUAD_MARINE 			23

#define JOB_FLAG_SPECIALNAME (1<<0)

#define CAPTAIN "Captain"
#define EXECUTIVE_OFFICER "Executive Officer" //Currently disabled.
#define FIELD_COMMANDER "Field Commander"
#define STAFF_OFFICER "Staff Officer"
#define PILOT_OFFICER "Pilot Officer"
#define REQUISITIONS_OFFICER "Requisitions Officer"
#define CHIEF_SHIP_ENGINEER "Chief Ship Engineer"
#define CHIEF_MEDICAL_OFFICER "Chief Medical Officer"
#define COMMAND_MASTER_AT_ARMS "Command Master at Arms"
#define TANK_CREWMAN "Tank Crewman"
#define CORPORATE_LIAISON "Corporate Liaison"
#define SYNTHETIC "Synthetic"
#define MASTER_AT_ARMS "Master at Arms"
#define SHIP_TECH "Ship Technician"
#define MEDICAL_OFFICER "Medical Officer"
#define MEDICAL_RESEARCHER "Medical Researcher"
#define TF_LEADER "ECHO Task Force Team Leader"
#define TF_MEMBER "ECHO Task Force Member"
#define SQUAD_LEADER "Squad Leader"
#define SQUAD_SPECIALIST "Squad Specialist"
#define SQUAD_SMARTGUNNER "Squad Smartgunner"
#define SQUAD_CORPSMAN "Squad Corpsman"
#define SQUAD_ENGINEER "Squad Engineer"
#define SQUAD_MARINE "Squad Marine"
#define SILICON_AI "AI"


GLOBAL_LIST_INIT(jobs_command, list(CAPTAIN, FIELD_COMMANDER, STAFF_OFFICER, PILOT_OFFICER, REQUISITIONS_OFFICER, CHIEF_SHIP_ENGINEER, \
CHIEF_MEDICAL_OFFICER, SYNTHETIC, SILICON_AI, COMMAND_MASTER_AT_ARMS))
GLOBAL_LIST_INIT(jobs_police, list(COMMAND_MASTER_AT_ARMS, MASTER_AT_ARMS))
GLOBAL_LIST_INIT(jobs_officers, list(CAPTAIN, FIELD_COMMANDER, STAFF_OFFICER, PILOT_OFFICER, TANK_CREWMAN, CORPORATE_LIAISON, SYNTHETIC, SILICON_AI))
GLOBAL_LIST_INIT(jobs_engineering, list(CHIEF_SHIP_ENGINEER, SHIP_TECH))
GLOBAL_LIST_INIT(jobs_requisitions, list(REQUISITIONS_OFFICER))
GLOBAL_LIST_INIT(jobs_medical, list(CHIEF_MEDICAL_OFFICER, MEDICAL_OFFICER, MEDICAL_RESEARCHER))
GLOBAL_LIST_INIT(jobs_marines, list(SQUAD_LEADER, SQUAD_SPECIALIST, SQUAD_SMARTGUNNER, SQUAD_CORPSMAN, SQUAD_ENGINEER, SQUAD_MARINE))
GLOBAL_LIST_INIT(jobs_regular_all, list(CAPTAIN, FIELD_COMMANDER, STAFF_OFFICER, PILOT_OFFICER, REQUISITIONS_OFFICER, CHIEF_SHIP_ENGINEER, \
CHIEF_MEDICAL_OFFICER, SYNTHETIC, SILICON_AI, COMMAND_MASTER_AT_ARMS, MASTER_AT_ARMS, TANK_CREWMAN, CORPORATE_LIAISON, SHIP_TECH, \
MEDICAL_OFFICER, MEDICAL_RESEARCHER, SQUAD_LEADER, SQUAD_SPECIALIST, SQUAD_SMARTGUNNER, SQUAD_CORPSMAN, SQUAD_ENGINEER, SQUAD_MARINE))
GLOBAL_LIST_INIT(jobs_unassigned, list(SQUAD_MARINE))


#define ROLE_XENOMORPH "Xenomorph"
#define ROLE_XENO_QUEEN "Xeno Queen"
#define ROLE_SURVIVOR "Survivor"
#define ROLE_ERT "Emergency Response Team"


//Playtime tracking system, see jobs_exp.dm
#define EXP_TYPE_LIVING			"Living"
#define EXP_TYPE_REGULAR_ALL	"Any"
#define EXP_TYPE_COMMAND		"Command"
#define EXP_TYPE_ENGINEERING	"Engineering"
#define EXP_TYPE_MEDICAL		"Medical"
#define EXP_TYPE_MARINES		"Marines"
#define EXP_TYPE_REQUISITIONS	"Requisitions"
#define EXP_TYPE_POLICE			"Police"
#define EXP_TYPE_SILICON		"Silicon"
#define EXP_TYPE_SPECIAL		"Special"
#define EXP_TYPE_GHOST			"Ghost"
#define EXP_TYPE_ADMIN			"Admin"

// hypersleep bay flags
#define CRYO_MED		"Medical"
#define CRYO_SEC		"Security"
#define CRYO_ENGI		"Engineering"
#define CRYO_REQ		"Requisitions"
#define CRYO_ALPHA		"Alpha Squad"
#define CRYO_BRAVO		"Bravo Squad"
#define CRYO_CHARLIE	"Charlie Squad"
#define CRYO_DELTA		"Delta Squad"
#define CRYO_ECHO		"Echo Squad"


#define XP_REQ_INTERMEDIATE 60
#define XP_REQ_EXPERIENCED 180

// how much a job is going to contribute towards burrowed larva. see config for points required to larva. old balance was 1 larva per 3 humans.
#define LARVA_POINTS_SHIPSIDE 1
#define LARVA_POINTS_SHIPSIDE_STRONG 2
#define LARVA_POINTS_REGULAR 3
#define LARVA_POINTS_STRONG 6
