package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import openfl.utils.Assets as OpenFlAssets;
#if cpp
import sys.FileSystem;
import sys.io.File;
#end
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.addons.effects.chainable.FlxGlitchEffect;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import openfl.display.Shader;
import openfl.filters.ShaderFilter;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import openfl.filters.ShaderFilter;
import openfl.filters.BitmapFilter;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;


using StringTools;

class PlayState extends MusicBeatState
{
	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	var halloweenLevel:Bool = false;

	private var vocals:FlxSound;

	private var dad:Character;
	private var gf:Character;
	private var boyfriend:Boyfriend;
	private var shadersLoaded:Bool = false;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	public var kps:Int = 0;
	public var kpsMax:Int = 0;
	private var time:Float = 0;

	private static var prevCamFollow:FlxObject;

	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;
	private var dadStrums:FlxTypedGroup<FlxSprite>;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	var timeTxt:FlxText;

	private var chromOn:Bool = false;
	private var vignetteOn:Bool = false;
	private var vignetteRadius:Float = 0.1;


	public var spinCamHud:Bool = false;
	public var spinCamGame:Bool = false;
	public var spinPlayerNotes:Bool = false;
	public var spinEnemyNotes:Bool = false;

	public var spinCamHudLeft:Bool = false;
	public var spinCamGameLeft:Bool = false;
	public var spinPlayerNotesLeft:Bool = false;
	public var spinEnemyNotesLeft:Bool = false;

	public var spinCamHudSpeed:Float = 0.5;
	public var spinCamGameSpeed:Float = 0.5;
	public var spinPlayerNotesSpeed:Float = 0.5;
	public var spinEnemyNotesSpeed:Float = 0.5;


	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	var filters:Array<BitmapFilter> = [];
	var camfilters:Array<BitmapFilter> = [];
	private var combo:Int = 0;
	private var misses:Int = 0;
	var totalAccuracy:Float = 0;
	var maxTotalAccuracy:Float = 0;
	var maxCombo:Int = 0;
	var totalRank:String = "S+";
	var songNotesHit:Int = 0;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	public var hitAccuracy:Array<Float> = [0];

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;
	var botAutoPlayAlert:FlxText;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();
	
	//QT Week
	var hazardRandom:Int = 1; //This integer is randomised upon song start between 1-5.
	var cessationTroll:FlxSprite;
	var streetBG:FlxSprite;
	var qt_tv01:FlxSprite;
	//For detecting if the song has already ended internally for Careless's end song dialogue or something -Haz.
	var qtCarelessFin:Bool = false; //If true, then the song has ended, allowing for the school intro to play end dialogue instead of starting dialogue.
	var qtCarelessFinCalled:Bool = false; //Used for terminates meme ending to stop it constantly firing code when song ends or something.
	//For Censory Overload -Haz
	var qt_gas01:FlxSprite;
	var qt_gas02:FlxSprite;
	public static var cutsceneSkip:Bool = false;
	//For changing the visuals -Haz
	var streetBGerror:FlxSprite;
	var streetFrontError:FlxSprite;
	var dad404:Character;
	var gf404:Character;
	var boyfriend404:Boyfriend;
	var qtIsBlueScreened:Bool = false;
	//Termination-playable
	var bfDodging:Bool = false;
	var bfCanDodge:Bool = false;
	var bfDodgeTiming:Float = 0.22625;
	var bfDodgeCooldown:Float = 0;
	var kb_attack_saw:FlxSprite;
	var bgFlash:FlxSprite;
	var kb_attack_alert:FlxSprite;
	var daSign:FlxSprite;
	var gramlan:FlxSprite;
	var sign:FlxSprite;
	var pincer1:FlxSprite;
	var pincer2:FlxSprite;
	var pincer3:FlxSprite;
	var pincer4:FlxSprite;
	public static var deathBySawBlade:Bool = false;
	var canSkipEndScreen:Bool = false; //This is set to true at the "thanks for playing" screen. Once true, in update, if enter is pressed it'll skip to the main menu.
	
        var vignette:FlxSprite;

	var talking:Bool = true;
	var songScore:Int = 0;
	var scoreTxt:FlxText;

	public static var deathCounter:Int = 0;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;


	var ch = 2 / 1000;

	var inCutscene:Bool = false;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var songLength:Float = 0;
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end


	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	// modifiers

	public static var instaFail:Bool = false;
	public static var noFail:Bool = false;
	public static var randomNotes:Bool = false;

	public static var seenCutscene:Bool = false;


	var spinMicBeat:Int = 0;
	var spinMicOffset:Int = 4;

	public var clicks:Array<Float> = [];

	private function CalculateKeysPerSecond()
	{

		for (i in 0 ... clicks.length)
		{
			if (clicks[i] <= time - 1)
			{
				clicks.remove(clicks[i]);
			}
		}
		kps = clicks.length;
	}

	override public function create()
	{



		
		Bind.keyCheck();
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();
		var noteSplash0:NoteSplash = new NoteSplash();
		noteSplash0.setupNoteSplash(100, 100, 0);
		grpNoteSplashes.add(noteSplash0);

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		camGame.setFilters(filters);
		camGame.filtersEnabled = true;
		camHUD.setFilters(camfilters);
		camHUD.filtersEnabled = true;

		persistentUpdate = true;
		persistentDraw = true;

		CoolUtil.preloadImages(this);

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		switch (SONG.song.toLowerCase())
		{
			case 'tutorial':
				dialogue = ["Hey you're pretty cute.", 'Use the arrow keys to keep up \nwith me singing.'];
			case 'bopeebo':
				dialogue = [
					'HEY!',
					"You think you can just sing\nwith my daughter like that?",
					"If you want to date her...",
					"You're going to have to go \nthrough ME first!"
				];
			case 'fresh':
				dialogue = ["Not too shabby boy.", ""];
			case 'dadbattle':
				dialogue = [
					"gah you think you're hot stuff?",
					"If you can beat me here...",
					"Only then I will even CONSIDER letting you\ndate my daughter!"
				];
			case 'senpai':
				dialogue = CoolUtil.coolTextFile(Paths.txt('senpai/senpaiDialogue'));
			case 'roses':
				dialogue = CoolUtil.coolTextFile(Paths.txt('roses/rosesDialogue'));
			case 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('thorns/thornsDialogue'));
			case 'carefree':
				dialogue = CoolUtil.coolTextFile(Paths.txt('carefree/carefreeDialogue'));
			case 'careless':
				dialogue = CoolUtil.coolTextFile(Paths.txt('careless/carelessDialogue'));
			case 'cessation':
				dialogue = CoolUtil.coolTextFile(Paths.txt('cessation/finalDialogue'));
			case 'censory-overload':
				dialogue = CoolUtil.coolTextFile(Paths.txt('censory-overload/censory-overloadDialogue'));
			case 'terminate':
				dialogue = CoolUtil.coolTextFile(Paths.txt('terminate/terminateDialogue'));
		}

		#if desktop
		// Making difficulty text for Discord Rich Presence.
		switch (storyDifficulty)
		{
			case 0:
				storyDifficultyText = "Easy";
			case 1:
				storyDifficultyText = "Normal";
			case 2:
				storyDifficultyText = "Hard";
		}

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " , "Misses:" + misses + " | " + "Score:" + songScore + " | " + "KPS:" + kps + "(" + kpsMax + ")" + " | " + "Accuracy:" + totalAccuracy + "%" + " | " + "Rank:" + totalRank, iconRPC);
		#end

		switch (SONG.song.toLowerCase())
		{
			case 'carefree': 
			{
				defaultCamZoom = 0.92125;
				//defaultCamZoom = 0.8125;
				curStage = 'streetCute';
				//Postitive = Right, Down
				//Negative = Left, Up
				var bg:FlxSprite = new FlxSprite(-750, -145).loadGraphic(Paths.image('stage/streetBackCute'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				add(bg);

				var streetFront:FlxSprite = new FlxSprite(-820, 710).loadGraphic(Paths.image('stage/streetFrontCute'));
				streetFront.setGraphicSize(Std.int(streetFront.width * 1.15));
				streetFront.updateHitbox();
				streetFront.antialiasing = true;
				streetFront.scrollFactor.set(0.9, 0.9);
				streetFront.active = false;
				add(streetFront);

				qt_tv01 = new FlxSprite(-62, 540).loadGraphic(Paths.image('stage/TV_V2_off'));
				qt_tv01.setGraphicSize(Std.int(qt_tv01.width * 1.2));
				qt_tv01.updateHitbox();
				qt_tv01.antialiasing = true;
				qt_tv01.scrollFactor.set(0.89, 0.89);
				qt_tv01.active = false;
				add(qt_tv01);
			}
			case 'cessation': 
			{
				defaultCamZoom = 0.8125;
				curStage = 'streetCute';
				var bg:FlxSprite = new FlxSprite(-750, -145).loadGraphic(Paths.image('stage/streetBackCute'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				add(bg);

				var streetFront:FlxSprite = new FlxSprite(-820, 710).loadGraphic(Paths.image('stage/streetFrontCute'));
				streetFront.setGraphicSize(Std.int(streetFront.width * 1.15));
				streetFront.updateHitbox();
				streetFront.antialiasing = true;
				streetFront.scrollFactor.set(0.9, 0.9);
				streetFront.active = false;
				add(streetFront);

				qt_tv01 = new FlxSprite();
				qt_tv01.frames = Paths.getSparrowAtlas('stage/TV_V4');
				qt_tv01.animation.addByPrefix('idle', 'TV_Idle', 24, true);	
				qt_tv01.animation.addByPrefix('alert', 'TV_Attention', 28, false);		
				qt_tv01.animation.addByPrefix('sus', 'TV_sus', 24, true);
				qt_tv01.animation.addByPrefix('heart', 'TV_End', 24, false);
				qt_tv01.setPosition(-62, 540);
				qt_tv01.setGraphicSize(Std.int(qt_tv01.width * 1.2));
				qt_tv01.updateHitbox();
				qt_tv01.antialiasing = true;
				qt_tv01.scrollFactor.set(0.89, 0.89);
				add(qt_tv01);
				qt_tv01.animation.play('heart');

				//Alert!
				kb_attack_alert = new FlxSprite();
				kb_attack_alert.frames = Paths.getSparrowAtlas('bonus/attack_alert_NEW');
				kb_attack_alert.animation.addByPrefix('alert', 'kb_attack_animation_alert-single', 24, false);	
				kb_attack_alert.antialiasing = true;
				kb_attack_alert.setGraphicSize(Std.int(kb_attack_alert.width * 1.5));
				kb_attack_alert.cameras = [camHUD];
				kb_attack_alert.x = FlxG.width - 700;
				kb_attack_alert.y = 205;

				cessationTroll = new FlxSprite(-62, 540).loadGraphic(Paths.image('bonus/justkidding'));
				cessationTroll.setGraphicSize(Std.int(cessationTroll.width * 0.9));
				cessationTroll.cameras = [camHUD];
				cessationTroll.x = FlxG.width - 950;
				cessationTroll.y = 205;
			}
			case 'careless': 
			{
				defaultCamZoom = 0.925;
				curStage = 'street';
				var bg:FlxSprite = new FlxSprite(-750, -145).loadGraphic(Paths.image('stage/streetBack'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				add(bg);

				var streetFront:FlxSprite = new FlxSprite(-820, 710).loadGraphic(Paths.image('stage/streetFront'));
				streetFront.setGraphicSize(Std.int(streetFront.width * 1.15));
				streetFront.updateHitbox();
				streetFront.antialiasing = true;
				streetFront.scrollFactor.set(0.9, 0.9);
				streetFront.active = false;
				add(streetFront);

				qt_tv01 = new FlxSprite();
				qt_tv01.frames = Paths.getSparrowAtlas('stage/TV_V5');
				qt_tv01.animation.addByPrefix('idle', 'TV_Idle', 24, true);
				qt_tv01.animation.addByPrefix('alert', 'TV_Attention', 26, false);
				//qt_tv01.animation.addByPrefix('eye', 'TV_eyes', 24, true);	
				qt_tv01.animation.addByPrefix('eye', 'TV_brutality', 24, true); //Replaced the hex eye with the brutality symbols for more accurate lore.
				qt_tv01.animation.addByPrefix('eyeLeft', 'TV_eyeLeft', 24, false);
				qt_tv01.animation.addByPrefix('eyeRight', 'TV_eyeRight', 24, false);

				qt_tv01.setPosition(-62, 540);
				qt_tv01.setGraphicSize(Std.int(qt_tv01.width * 1.2));
				qt_tv01.updateHitbox();
				qt_tv01.antialiasing = true;
				qt_tv01.scrollFactor.set(0.89, 0.89);
				add(qt_tv01);
				qt_tv01.animation.play('idle');
			}
			case 'censory-overload': 
			{
				defaultCamZoom = 0.8125;
				
				curStage = 'streetFinal';

				if(!Main.qtOptimisation){
					//Far Back Layer - Error (blue screen)
					var errorBG:FlxSprite = new FlxSprite(-750, -145).loadGraphic(Paths.image('stage/streetError'));
					errorBG.antialiasing = true;
					errorBG.scrollFactor.set(0.9, 0.9);
					errorBG.active = false;
					add(errorBG);

					//Back Layer - Error (glitched version of normal Back)
					streetBGerror = new FlxSprite(-750, -145).loadGraphic(Paths.image('stage/streetBackError'));
					streetBGerror.antialiasing = true;
					streetBGerror.scrollFactor.set(0.9, 0.9);
					add(streetBGerror);
				}

				//Back Layer - Normal
				streetBG = new FlxSprite(-750, -145).loadGraphic(Paths.image('stage/streetBack'));
				streetBG.antialiasing = true;
				streetBG.scrollFactor.set(0.9, 0.9);
				add(streetBG);


				//Front Layer - Normal
				var streetFront:FlxSprite = new FlxSprite(-820, 710).loadGraphic(Paths.image('stage/streetFront'));
				streetFront.setGraphicSize(Std.int(streetFront.width * 1.15));
				streetFront.updateHitbox();
				streetFront.antialiasing = true;
				streetFront.scrollFactor.set(0.9, 0.9);
				streetFront.active = false;
				add(streetFront);

				if(!Main.qtOptimisation){
					//Front Layer - Error (changes to have a glow)
					streetFrontError = new FlxSprite(-820, 710).loadGraphic(Paths.image('stage/streetFrontError'));
					streetFrontError.setGraphicSize(Std.int(streetFrontError.width * 1.15));
					streetFrontError.updateHitbox();
					streetFrontError.antialiasing = true;
					streetFrontError.scrollFactor.set(0.9, 0.9);
					streetFrontError.active = false;
					add(streetFrontError);
					streetFrontError.visible = false;
				}


				qt_tv01 = new FlxSprite();
				qt_tv01.frames = Paths.getSparrowAtlas('stage/TV_V5');
				qt_tv01.animation.addByPrefix('idle', 'TV_Idle', 24, true);
				qt_tv01.animation.addByPrefix('eye', 'TV_brutality', 24, true); //Replaced the hex eye with the brutality symbols for more accurate lore.
				qt_tv01.animation.addByPrefix('error', 'TV_Error', 24, true);	
				qt_tv01.animation.addByPrefix('404', 'TV_Bluescreen', 24, true);		
				qt_tv01.animation.addByPrefix('alert', 'TV_Attention', 32, false);		
				qt_tv01.animation.addByPrefix('watch', 'TV_Watchout', 24, true);
				qt_tv01.animation.addByPrefix('drop', 'TV_Drop', 24, true);
				qt_tv01.animation.addByPrefix('sus', 'TV_sus', 24, true);
				qt_tv01.setPosition(-62, 540);
				qt_tv01.setGraphicSize(Std.int(qt_tv01.width * 1.2));
				qt_tv01.updateHitbox();
				qt_tv01.antialiasing = true;
				qt_tv01.scrollFactor.set(0.89, 0.89);
				add(qt_tv01);
				qt_tv01.animation.play('idle');

				//https://youtu.be/Nz0qjc8WRyY?t=1749
				//Wow, I guess it's that easy huh? -Haz
				if(!Main.qtOptimisation){
					boyfriend404 = new Boyfriend(770, 450, 'bf_404');
					dad404 = new Character(100,100,'robot_404');
					gf404 = new Character(400,130,'gf_404');
					gf404.scrollFactor.set(0.95, 0.95);

					//These are set to 0 on first step. Not 0 here because otherwise they aren't cached in properly or something?
					//I dunno
					boyfriend404.alpha = 0.0125; 
					dad404.alpha = 0.0125;
					gf404.alpha = 0.0125;

					//Probably a better way of doing this... too bad! -Haz
					qt_gas01 = new FlxSprite();
					//Old gas sprites.
					//qt_gas01.frames = Paths.getSparrowAtlas('stage/gas_test');
					//qt_gas01.animation.addByPrefix('burst', 'ezgif.com-gif-makernew_gif instance ', 30, false);	

					//Left gas
					qt_gas01.frames = Paths.getSparrowAtlas('stage/Gas_Release');
					qt_gas01.animation.addByPrefix('burst', 'Gas_Release', 38, false);	
					qt_gas01.animation.addByPrefix('burstALT', 'Gas_Release', 49, false);
					qt_gas01.animation.addByPrefix('burstFAST', 'Gas_Release', 76, false);	
					qt_gas01.setGraphicSize(Std.int(qt_gas01.width * 2.5));	
					qt_gas01.antialiasing = true;
					qt_gas01.scrollFactor.set();
					qt_gas01.alpha = 0.72;
					qt_gas01.setPosition(-880,-100);
					qt_gas01.angle = -31;				

					//Right gas
					qt_gas02 = new FlxSprite();
					//qt_gas02.frames = Paths.getSparrowAtlas('stage/gas_test');
					//qt_gas02.animation.addByPrefix('burst', 'ezgif.com-gif-makernew_gif instance ', 30, false);

					qt_gas02.frames = Paths.getSparrowAtlas('stage/Gas_Release');
					qt_gas02.animation.addByPrefix('burst', 'Gas_Release', 38, false);	
					qt_gas02.animation.addByPrefix('burstALT', 'Gas_Release', 49, false);
					qt_gas02.animation.addByPrefix('burstFAST', 'Gas_Release', 76, false);	
					qt_gas02.setGraphicSize(Std.int(qt_gas02.width * 2.5));
					qt_gas02.antialiasing = true;
					qt_gas02.scrollFactor.set();
					qt_gas02.alpha = 0.72;
					qt_gas02.setPosition(920,-100);
					qt_gas02.angle = 31;
				}
			}
			case 'terminate':
			{
				defaultCamZoom = 0.8125;
				curStage = 'street';
				var bg:FlxSprite = new FlxSprite(-750, -145).loadGraphic(Paths.image('stage/streetBack'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				add(bg);

				var streetFront:FlxSprite = new FlxSprite(-820, 710).loadGraphic(Paths.image('stage/streetFront'));
				streetFront.setGraphicSize(Std.int(streetFront.width * 1.15));
				streetFront.updateHitbox();
				streetFront.antialiasing = true;
				streetFront.scrollFactor.set(0.9, 0.9);
				streetFront.active = false;
				add(streetFront);

				qt_tv01 = new FlxSprite();
				qt_tv01.frames = Paths.getSparrowAtlas('stage/TV_V5');
				qt_tv01.animation.addByPrefix('idle', 'TV_Idle', 24, true);
				qt_tv01.animation.addByPrefix('error', 'TV_Error', 24, true);
					
				qt_tv01.setPosition(-62, 540);
				qt_tv01.setGraphicSize(Std.int(qt_tv01.width * 1.2));
				qt_tv01.updateHitbox();
				qt_tv01.antialiasing = true;
				qt_tv01.scrollFactor.set(0.89, 0.89);
				add(qt_tv01);
				qt_tv01.animation.play('idle');
			}
			case 'termination': //Seperated the two so terminate can load quicker (doesn't need to load in the attack animations and stuff)
			{
				defaultCamZoom = 0.8125;
				
				curStage = 'streetFinal';

				if(!Main.qtOptimisation){
					//Far Back Layer - Error (blue screen)
					var errorBG:FlxSprite = new FlxSprite(-600, -150).loadGraphic(Paths.image('stage/streetError'));
					errorBG.antialiasing = true;
					errorBG.scrollFactor.set(0.9, 0.9);
					errorBG.active = false;
					add(errorBG);

					//Back Layer - Error (glitched version of normal Back)
					streetBGerror = new FlxSprite(-750, -145).loadGraphic(Paths.image('stage/streetBackError'));
					streetBGerror.antialiasing = true;
					streetBGerror.scrollFactor.set(0.9, 0.9);
					add(streetBGerror);
				}

				//Back Layer - Normal
				streetBG = new FlxSprite(-750, -145).loadGraphic(Paths.image('stage/streetBack'));
				streetBG.antialiasing = true;
				streetBG.scrollFactor.set(0.9, 0.9);
				add(streetBG);


				//Front Layer - Normal
				var streetFront:FlxSprite = new FlxSprite(-820, 710).loadGraphic(Paths.image('stage/streetFront'));
				streetFront.setGraphicSize(Std.int(streetFront.width * 1.15));
				streetFront.updateHitbox();
				streetFront.antialiasing = true;
				streetFront.scrollFactor.set(0.9, 0.9);
				streetFront.active = false;
				add(streetFront);

				if(!Main.qtOptimisation){
					//Front Layer - Error (changes to have a glow)
					streetFrontError = new FlxSprite(-820, 710).loadGraphic(Paths.image('stage/streetFrontError'));
					streetFrontError.setGraphicSize(Std.int(streetFrontError.width * 1.15));
					streetFrontError.updateHitbox();
					streetFrontError.antialiasing = true;
					streetFrontError.scrollFactor.set(0.9, 0.9);
					streetFrontError.active = false;
					add(streetFrontError);
					streetFrontError.visible = false;
				}

				qt_tv01 = new FlxSprite();
				qt_tv01.frames = Paths.getSparrowAtlas('stage/TV_V5');
				qt_tv01.animation.addByPrefix('idle', 'TV_Idle', 24, true);
				qt_tv01.animation.addByPrefix('eye', 'TV_brutality', 24, true); //Replaced the hex eye with the brutality symbols for more accurate lore.
				qt_tv01.animation.addByPrefix('eyeRight', 'TV_eyeRight', 24, true);
				qt_tv01.animation.addByPrefix('eyeLeft', 'TV_eyeLeft', 24, true);
				qt_tv01.animation.addByPrefix('error', 'TV_Error', 24, true);	
				qt_tv01.animation.addByPrefix('404', 'TV_Bluescreen', 24, true);		
				qt_tv01.animation.addByPrefix('alert', 'TV_Attention', 36, false);		
				qt_tv01.animation.addByPrefix('watch', 'TV_Watchout', 24, true);
				qt_tv01.animation.addByPrefix('drop', 'TV_Drop', 24, true);
				qt_tv01.animation.addByPrefix('sus', 'TV_sus', 24, true);
				qt_tv01.animation.addByPrefix('instructions', 'TV_Instructions-Normal', 24, true);
				qt_tv01.animation.addByPrefix('gl', 'TV_GoodLuck', 24, true);
				qt_tv01.setPosition(-62, 540);
				qt_tv01.setGraphicSize(Std.int(qt_tv01.width * 1.2));
				qt_tv01.updateHitbox();
				qt_tv01.antialiasing = true;
				qt_tv01.scrollFactor.set(0.89, 0.89);
				add(qt_tv01);
				qt_tv01.animation.play('idle');


				//https://youtu.be/Nz0qjc8WRyY?t=1749
				//Wow, I guess it's that easy huh? -Haz
				if(!Main.qtOptimisation){
					boyfriend404 = new Boyfriend(770, 450, 'bf_404');
					dad404 = new Character(100,100,'robot_404-TERMINATION');
					gf404 = new Character(400,130,'gf_404');
					gf404.scrollFactor.set(0.95, 0.95);

					//These are set to 0 on first step. Not 0 here because otherwise they aren't cached in properly or something?
					//I dunno
					boyfriend404.alpha = 0.0125; 
					dad404.alpha = 0.0125;
					gf404.alpha = 0.0125;
				}

				//Alert!
				kb_attack_alert = new FlxSprite();
				kb_attack_alert.frames = Paths.getSparrowAtlas('bonus/attack_alert_NEW');
				kb_attack_alert.animation.addByPrefix('alert', 'kb_attack_animation_alert-single', 24, false);	
				kb_attack_alert.animation.addByPrefix('alertDOUBLE', 'kb_attack_animation_alert-double', 24, false);	
				kb_attack_alert.antialiasing = true;
				kb_attack_alert.setGraphicSize(Std.int(kb_attack_alert.width * 1.5));
				kb_attack_alert.cameras = [camHUD];
				kb_attack_alert.x = FlxG.width - 700;
				kb_attack_alert.y = 205;
				//kb_attack_alert.animation.play("alert"); //Placeholder, change this to start already hidden or whatever.

				//Saw that one coming!
				kb_attack_saw = new FlxSprite();
				kb_attack_saw.frames = Paths.getSparrowAtlas('bonus/attackv6');
				kb_attack_saw.animation.addByPrefix('fire', 'kb_attack_animation_fire', 24, false);	
				kb_attack_saw.animation.addByPrefix('prepare', 'kb_attack_animation_prepare', 24, false);	
				kb_attack_saw.setGraphicSize(Std.int(kb_attack_saw.width * 1.15));
				kb_attack_saw.antialiasing = true;
				kb_attack_saw.setPosition(-860,615);

				//Pincer shit for moving notes around for a little bit of trollin'
				pincer1 = new FlxSprite(0, 0).loadGraphic(Paths.image('bonus/pincer-close'));
				pincer1.antialiasing = true;
				pincer1.scrollFactor.set();
				
				pincer2 = new FlxSprite(0, 0).loadGraphic(Paths.image('bonus/pincer-close'));
				pincer2.antialiasing = true;
				pincer2.scrollFactor.set();
				
				pincer3 = new FlxSprite(0, 0).loadGraphic(Paths.image('bonus/pincer-close'));
				pincer3.antialiasing = true;
				pincer3.scrollFactor.set();

				pincer4 = new FlxSprite(0, 0).loadGraphic(Paths.image('bonus/pincer-close'));
				pincer4.antialiasing = true;
				pincer4.scrollFactor.set();
				
				if (FlxG.save.data.downscroll){
					pincer4.angle = 270;
					pincer3.angle = 270;
					pincer2.angle = 270;
					pincer1.angle = 270;
					pincer1.offset.set(192,-75);
					pincer2.offset.set(192,-75);
					pincer3.offset.set(192,-75);
					pincer4.offset.set(192,-75);
				}else{
					pincer4.angle = 90;
					pincer3.angle = 90;
					pincer2.angle = 90;
					pincer1.angle = 90;
					pincer1.offset.set(218,240);
					pincer2.offset.set(218,240);
					pincer3.offset.set(218,240);
					pincer4.offset.set(218,240);
				}
			}
                        case 'spookeez' | 'monster' | 'south': 
                        {
                                curStage = 'spooky';
	                          halloweenLevel = true;

		                  var hallowTex = Paths.getSparrowAtlas('halloween_bg');

	                          halloweenBG = new FlxSprite(-200, -100);
		                  halloweenBG.frames = hallowTex;
	                          halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
	                          halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
	                          halloweenBG.animation.play('idle');
	                          halloweenBG.antialiasing = true;
	                          add(halloweenBG);

		                  isHalloween = true;
			}
			case 'extermination': //Seperated the two so exterminate can load quicker (doesn't need to load in the attack animations and stuff)
			{
				defaultCamZoom = 0.8125;
				
				curStage = 'streetFinal';

				if(!Main.qtOptimisation){
					//Far Back Layer - Error (blue screen)
					var errorBG:FlxSprite = new FlxSprite(-600, -150).loadGraphic(Paths.image('stage/streetError'));
					errorBG.antialiasing = true;
					errorBG.scrollFactor.set(0.9, 0.9);
					errorBG.active = false;
					add(errorBG);

					//Back Layer - Error (glitched version of normal Back)
					streetBGerror = new FlxSprite(-750, -145).loadGraphic(Paths.image('stage/streetBackError'));
					streetBGerror.antialiasing = true;
					streetBGerror.scrollFactor.set(0.9, 0.9);
					add(streetBGerror);
				}

				//Back Layer - Normal
				streetBG = new FlxSprite(-750, -145).loadGraphic(Paths.image('stage/streetBack'));
				streetBG.antialiasing = true;
				streetBG.scrollFactor.set(0.9, 0.9);
				add(streetBG);


				//Front Layer - Normal
				var streetFront:FlxSprite = new FlxSprite(-820, 710).loadGraphic(Paths.image('stage/streetFront'));
				streetFront.setGraphicSize(Std.int(streetFront.width * 1.15));
				streetFront.updateHitbox();
				streetFront.antialiasing = true;
				streetFront.scrollFactor.set(0.9, 0.9);
				streetFront.active = false;
				add(streetFront);

				if(!Main.qtOptimisation){
					//Front Layer - Error (changes to have a glow)
					streetFrontError = new FlxSprite(-820, 710).loadGraphic(Paths.image('stage/streetFrontError'));
					streetFrontError.setGraphicSize(Std.int(streetFrontError.width * 1.15));
					streetFrontError.updateHitbox();
					streetFrontError.antialiasing = true;
					streetFrontError.scrollFactor.set(0.9, 0.9);
					streetFrontError.active = false;
					add(streetFrontError);
					streetFrontError.visible = false;
				}

				qt_tv01 = new FlxSprite();
				qt_tv01.frames = Paths.getSparrowAtlas('stage/TV_V5');
				qt_tv01.animation.addByPrefix('idle', 'TV_Idle', 24, true);
				qt_tv01.animation.addByPrefix('eye', 'TV_brutality', 24, true); //Replaced the hex eye with the brutality symbols for more accurate lore.
				qt_tv01.animation.addByPrefix('eyeRight', 'TV_eyeRight', 24, true);
				qt_tv01.animation.addByPrefix('eyeLeft', 'TV_eyeLeft', 24, true);
				qt_tv01.animation.addByPrefix('error', 'TV_Error', 24, true);	
				qt_tv01.animation.addByPrefix('404', 'TV_Bluescreen', 24, true);		
				qt_tv01.animation.addByPrefix('alert', 'TV_Attention', 36, false);		
				qt_tv01.animation.addByPrefix('watch', 'TV_Watchout', 24, true);
				qt_tv01.animation.addByPrefix('drop', 'TV_Drop', 24, true);
				qt_tv01.animation.addByPrefix('sus', 'TV_sus', 24, true);
				qt_tv01.animation.addByPrefix('instructions', 'TV_Instructions-Normal', 24, true);
				qt_tv01.animation.addByPrefix('instructions_ALT', 'TV_Instructions-ALT', 24, true);
				qt_tv01.animation.addByPrefix('gl', 'TV_GoodLuck', 24, true);
				qt_tv01.setPosition(-62, 540);
				qt_tv01.setGraphicSize(Std.int(qt_tv01.width * 1.2));
				qt_tv01.updateHitbox();
				qt_tv01.antialiasing = true;
				qt_tv01.scrollFactor.set(0.89, 0.89);
				add(qt_tv01);
				qt_tv01.animation.play('idle');


				//https://youtu.be/Nz0qjc8WRyY?t=1749
				//Wow, I guess it's that easy huh? -Haz
				if(!Main.qtOptimisation){
					boyfriend404 = new Boyfriend(770, 450, 'bf_404');
						if (PlayState.SONG.player1 == 'compota'){
							boyfriend404 = new Boyfriend(770, 450, 'compota');
						}
					dad404 = new Character(100,100,'robot_404-TERMINATION');
						if (PlayState.SONG.player2 == 'compota'){
							dad404 = new Character(100,100, 'compota');
						}
					gf404 = new Character(400,130,'gf_404');
					gf404.scrollFactor.set(0.95, 0.95);

					//These are set to 0 on first step. Not 0 here because otherwise they aren't cached in properly or something?
					//I dunno
					boyfriend404.alpha = 0.0125; 
					dad404.alpha = 0.0125;
					gf404.alpha = 0.0125;
				}

				if(!Main.qtOptimisation){
					bgFlash = new FlxSprite(-820, 710).loadGraphic(Paths.image('bonus/bgFlash'));
					bgFlash.frames = Paths.getSparrowAtlas('bonus/bgFlash');
					bgFlash.animation.addByPrefix('bg_Flash_Normal', 'bg_Flash', 24, false);
					bgFlash.animation.addByPrefix('bg_Flash_Long', 'bgFlash_Long', 24, false);
					bgFlash.animation.addByPrefix('bg_Flash_Critical', 'bgFlash_Critical_perBeat', 24, false);
					bgFlash.animation.addByPrefix('bg_Flash_Critical_Long', 'bgFlashCritical_Long', 24, false);
					bgFlash.antialiasing = true;
					bgFlash.setGraphicSize(Std.int(bgFlash.width * 1.15));
					bgFlash.cameras = [camHUD];
					bgFlash.setPosition(0,0);
				}

				//Alert!
				kb_attack_alert = new FlxSprite();
				kb_attack_alert.frames = Paths.getSparrowAtlas('bonus/attack_alert_NEW_with_EXTRAS');
				kb_attack_alert.animation.addByPrefix('alert', 'kb_attack_animation_alert-single', 24, false);	
				kb_attack_alert.animation.addByPrefix('alertDOUBLE', 'kb_attack_animation_alert-double', 24, false);	
				kb_attack_alert.antialiasing = true;
				kb_attack_alert.setGraphicSize(Std.int(kb_attack_alert.width * 1.5));
				kb_attack_alert.cameras = [camHUD];
				kb_attack_alert.x = FlxG.width - 700;
				kb_attack_alert.y = 205;
				//kb_attack_alert.animation.play("alert"); //Placeholder, change this to start already hidden or whatever.

				//Saw that one coming!
				kb_attack_saw = new FlxSprite();
				kb_attack_saw.frames = Paths.getSparrowAtlas('bonus/attackv6');
				kb_attack_saw.animation.addByPrefix('fire', 'kb_attack_animation_fire', 24, false);	
				kb_attack_saw.animation.addByPrefix('prepare', 'kb_attack_animation_prepare', 24, false);	
				kb_attack_saw.setGraphicSize(Std.int(kb_attack_saw.width * 1.15));
				kb_attack_saw.antialiasing = true;
				kb_attack_saw.setPosition(-860,615);

				//Pincer shit for moving notes around for a little bit of trollin'
				pincer1 = new FlxSprite(0, 0).loadGraphic(Paths.image('bonus/pincer-close'));
				pincer1.antialiasing = true;
				pincer1.scrollFactor.set();
				
				pincer2 = new FlxSprite(0, 0).loadGraphic(Paths.image('bonus/pincer-close'));
				pincer2.antialiasing = true;
				pincer2.scrollFactor.set();
				
				pincer3 = new FlxSprite(0, 0).loadGraphic(Paths.image('bonus/pincer-close'));
				pincer3.antialiasing = true;
				pincer3.scrollFactor.set();

				pincer4 = new FlxSprite(0, 0).loadGraphic(Paths.image('bonus/pincer-close'));
				pincer4.antialiasing = true;
				pincer4.scrollFactor.set();
				
				if (FlxG.save.data.downscroll){
					pincer4.angle = 270;
					pincer3.angle = 270;
					pincer2.angle = 270;
					pincer1.angle = 270;
					pincer1.offset.set(192,-75);
					pincer2.offset.set(192,-75);
					pincer3.offset.set(192,-75);
					pincer4.offset.set(192,-75);
				}else{
					pincer4.angle = 90;
					pincer3.angle = 90;
					pincer2.angle = 90;
					pincer1.angle = 90;
					pincer1.offset.set(218,240);
					pincer2.offset.set(218,240);
					pincer3.offset.set(218,240);
					pincer4.offset.set(218,240);
				}
			}
			case 'expurgation': //Oh fuck...
			{
				defaultCamZoom = 0.725;
				
				curStage = 'streetFinal';

				if(!Main.qtOptimisation){
					//Far Back Layer - Error (blue screen)
					var errorBG:FlxSprite = new FlxSprite(-600, -150).loadGraphic(Paths.image('stage/streetError'));
					errorBG.antialiasing = true;
					errorBG.scrollFactor.set(0.9, 0.9);
					errorBG.active = false;
					add(errorBG);

					//Back Layer - Error (glitched version of normal Back)
					streetBGerror = new FlxSprite(-750, -145).loadGraphic(Paths.image('stage/streetBackError'));
					streetBGerror.antialiasing = true;
					streetBGerror.scrollFactor.set(0.9, 0.9);
					add(streetBGerror);
				}

				//Back Layer - Normal
				streetBG = new FlxSprite(-750, -145).loadGraphic(Paths.image('stage/streetBack'));
				streetBG.antialiasing = true;
				streetBG.scrollFactor.set(0.9, 0.9);
				add(streetBG);


				//Front Layer - Normal
				var streetFront:FlxSprite = new FlxSprite(-820, 710).loadGraphic(Paths.image('stage/streetFront'));
				streetFront.setGraphicSize(Std.int(streetFront.width * 1.15));
				streetFront.updateHitbox();
				streetFront.antialiasing = true;
				streetFront.scrollFactor.set(0.9, 0.9);
				streetFront.active = false;
				add(streetFront);

				if(!Main.qtOptimisation){
					//Front Layer - Error (changes to have a glow)
					streetFrontError = new FlxSprite(-820, 710).loadGraphic(Paths.image('stage/streetFrontError'));
					streetFrontError.setGraphicSize(Std.int(streetFrontError.width * 1.15));
					streetFrontError.updateHitbox();
					streetFrontError.antialiasing = true;
					streetFrontError.scrollFactor.set(0.9, 0.9);
					streetFrontError.active = false;
					add(streetFrontError);
					streetFrontError.visible = false;
				}

				qt_tv01 = new FlxSprite();
				qt_tv01.frames = Paths.getSparrowAtlas('stage/TV_V5');
				qt_tv01.animation.addByPrefix('idle', 'TV_Idle', 24, true);
				qt_tv01.animation.addByPrefix('eye', 'TV_brutality', 24, true); //Replaced the hex eye with the brutality symbols for more accurate lore.
				qt_tv01.animation.addByPrefix('eyeRight', 'TV_eyeRight', 24, true);
				qt_tv01.animation.addByPrefix('eyeLeft', 'TV_eyeLeft', 24, true);
				qt_tv01.animation.addByPrefix('error', 'TV_Error', 24, true);	
				qt_tv01.animation.addByPrefix('404', 'TV_Bluescreen', 24, true);		
				qt_tv01.animation.addByPrefix('alert', 'TV_Attention', 36, false);		
				qt_tv01.animation.addByPrefix('watch', 'TV_Watchout', 24, true);
				qt_tv01.animation.addByPrefix('drop', 'TV_Drop', 24, true);
				qt_tv01.animation.addByPrefix('sus', 'TV_sus', 24, true);
				qt_tv01.animation.addByPrefix('instructions', 'TV_Instructions-Normal', 24, true);
				qt_tv01.animation.addByPrefix('gl', 'TV_GoodLuck', 24, true);
				qt_tv01.setPosition(-62, 540);
				qt_tv01.setGraphicSize(Std.int(qt_tv01.width * 1.2));
				qt_tv01.updateHitbox();
				qt_tv01.antialiasing = true;
				qt_tv01.scrollFactor.set(0.89, 0.89);
				add(qt_tv01);
				qt_tv01.animation.play('idle');

				sign = new FlxSprite();
				sign.frames = Paths.getSparrowAtlas('bonus/Sign');
				sign.animation.addByPrefix('normal', 'Sign_Static', 24, true);
				sign.animation.addByPrefix('bluescreen', 'Sign_on_Bluescreen', 24, true);
				sign.antialiasing = true;
				sign.setGraphicSize(Std.int(sign.width * 0.67));
				sign.setPosition(1100, 110);
				add(sign);
				sign.animation.play('normal');

				//https://youtu.be/Nz0qjc8WRyY?t=1749
				//Wow, I guess it's that easy huh? -Haz
				if(!Main.qtOptimisation){
					boyfriend404 = new Boyfriend(770, 450, 'bf_404');
						if (PlayState.SONG.player1 == 'compota'){
							boyfriend404 = new Boyfriend(770, 450, 'compota');
						}
					dad404 = new Character(100,100,'robot_404-TERMINATION');
						if (PlayState.SONG.player2 == 'compota'){
							dad404 = new Character(100,100, 'compota');
						}
					gf404 = new Character(400,130,'gf_404');
					gf404.scrollFactor.set(0.95, 0.95);

					//These are set to 0 on first step. Not 0 here because otherwise they aren't cached in properly or something?
					//I dunno
					boyfriend404.alpha = 0.0125; 
					dad404.alpha = 0.0125;
					gf404.alpha = 0.0125;
				}

				//Alert!
				kb_attack_alert = new FlxSprite();
				kb_attack_alert.frames = Paths.getSparrowAtlas('bonus/attack_alert_NEW_with_EXTRAS');
				kb_attack_alert.animation.addByPrefix('alert', 'kb_attack_animation_alert-single', 24, false);	
				kb_attack_alert.animation.addByPrefix('alertDOUBLE', 'kb_attack_animation_alert-double', 24, false);	
				kb_attack_alert.antialiasing = true;
				kb_attack_alert.setGraphicSize(Std.int(kb_attack_alert.width * 1.5));
				kb_attack_alert.cameras = [camHUD];
				kb_attack_alert.x = FlxG.width - 700;
				kb_attack_alert.y = 205;
				//kb_attack_alert.animation.play("alert"); //Placeholder, change this to start already hidden or whatever.

				//Saw that one coming!
				kb_attack_saw = new FlxSprite();
				kb_attack_saw.frames = Paths.getSparrowAtlas('bonus/attackv6');
				kb_attack_saw.animation.addByPrefix('fire', 'kb_attack_animation_fire', 24, false);	
				kb_attack_saw.animation.addByPrefix('prepare', 'kb_attack_animation_prepare', 24, false);	
				kb_attack_saw.setGraphicSize(Std.int(kb_attack_saw.width * 1.15));
				kb_attack_saw.antialiasing = true;
				kb_attack_saw.setPosition(-860,615);

				daSign = new FlxSprite();
				daSign.frames = Paths.getSparrowAtlas('Sign_Post_Mechanic');
				daSign.setGraphicSize(Std.int(daSign.width * 0.67));
				daSign.cameras = [camHUD];

				gramlan = new FlxSprite();
				gramlan.frames = Paths.getSparrowAtlas('HP GREMLIN');
				gramlan.setGraphicSize(Std.int(gramlan.width * 0.76));
				gramlan.cameras = [camHUD];
		          }
		          case 'pico' | 'blammed' | 'philly': 
                          {
		                  curStage = 'philly';

		                  var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky'));
		                  bg.scrollFactor.set(0.1, 0.1);
		                  add(bg);

	                          var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city'));
		                  city.scrollFactor.set(0.3, 0.3);
		                  city.setGraphicSize(Std.int(city.width * 0.85));
		                  city.updateHitbox();
		                  add(city);

		                  phillyCityLights = new FlxTypedGroup<FlxSprite>();
		                  add(phillyCityLights);

		                  for (i in 0...5)
		                  {
		                          var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i));
		                          light.scrollFactor.set(0.3, 0.3);
		                          light.visible = false;
		                          light.setGraphicSize(Std.int(light.width * 0.85));
		                          light.updateHitbox();
		                          light.antialiasing = true;
		                          phillyCityLights.add(light);
		                  }

		                  var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain'));
		                  add(streetBehind);

	                          phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train'));
		                  add(phillyTrain);

		                  trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
		                  FlxG.sound.list.add(trainSound);

		                  // var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

		                  var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street'));
	                          add(street);
			}
			//Okay, so erm... I was going to add secret song to the QT mod which would introduce you to "her"... but I scrapped it due to not making much sense (BF has no involvement with Brutality).
			case 'redacted': 
			{
				defaultCamZoom = 0.45;
				curStage = 'nightmare';

				var bg:FlxSprite = new FlxSprite(-750, -200).loadGraphic(Paths.image('weeb/pixelUI/ssshhh/redacted/nightmare_gradient'));
				bg.antialiasing = true;
				bg.screenCenter();
				bg.scrollFactor.set(0,0);
				bg.active = false;
				add(bg);
				var floor:FlxSprite = new FlxSprite(-750, -200).loadGraphic(Paths.image('weeb/pixelUI/ssshhh/redacted/nightmare'));
				floor.antialiasing = true;
				floor.scrollFactor.set(0.9, 0.9);
				floor.active = false;
				add(floor);


				boyfriend404 = new Boyfriend(770, 450, 'bf');
				boyfriend404.alpha = 0.0125;
				//So that the game doesn't crash lmao
				dad404 = new Character(100,100,'monster');
				gf404 = new Character(400,130,'gf_404');
				gf404.scrollFactor.set(0.95, 0.95);
				dad404.alpha = 0;
				gf404.alpha = 0;

				vignette = new FlxSprite().loadGraphic(Paths.image('weeb/pixelUI/ssshhh/redacted/vignette'));
				vignette.updateHitbox();
				vignette.screenCenter();
				vignette.scrollFactor.set(0,0);
				//vignette.setGraphicSize(Std.int(vignette.width * 0.8));
				vignette.antialiasing = true;
				add(vignette);
				vignette.cameras = [camHUD];

				qt_tv01 = new FlxSprite();
				qt_tv01.frames = Paths.getSparrowAtlas('weeb/pixelUI/ssshhh/redacted/TV_secret');
				qt_tv01.animation.addByPrefix('idle', 'TVSINGLE-IDLE', 24, true);
				qt_tv01.animation.addByPrefix('part1', 'TVSINGLE-01', 24, true);
				qt_tv01.animation.addByPrefix('part2', 'TVSINGLE-02', 24, true);
				qt_tv01.animation.addByPrefix('part3', 'TVSINGLE-03', 24, true);
				qt_tv01.animation.addByPrefix('part4', 'TVSINGLE-04', 24, true);

				//qt_tv01.animation.addByPrefix('alert', 'TV_Attention', 26, false);

				qt_tv01.setPosition(-62, 540);
				qt_tv01.setGraphicSize(Std.int(qt_tv01.width * 1.2));
				qt_tv01.updateHitbox();
				qt_tv01.antialiasing = true;
				qt_tv01.scrollFactor.set(0.89, 0.89);
				add(qt_tv01);
				qt_tv01.animation.play('idle');

				//Alert!
				kb_attack_alert = new FlxSprite();
				kb_attack_alert.frames = Paths.getSparrowAtlas('bonus/attack_alert_NEW');
				kb_attack_alert.animation.addByPrefix('alert', 'kb_attack_animation_alert-single', 24, false);	
				kb_attack_alert.animation.addByPrefix('alertDOUBLE', 'kb_attack_animation_alert-double', 24, false);	
				kb_attack_alert.antialiasing = true;
				kb_attack_alert.setGraphicSize(Std.int(kb_attack_alert.width * 1.5));
				kb_attack_alert.cameras = [camHUD];
				kb_attack_alert.x = FlxG.width - 700;
				kb_attack_alert.y = 205;
				kb_attack_alert.alpha = 0.2;
		          }
		          case 'satin-panties' | 'high':
		          {
		                  curStage = 'limo';
		                  defaultCamZoom = 0.90;

		                  var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset'));
		                  skyBG.scrollFactor.set(0.1, 0.1);
		                  add(skyBG);

		                  var bgLimo:FlxSprite = new FlxSprite(-200, 480);
		                  bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo');
		                  bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
		                  bgLimo.animation.play('drive');
		                  bgLimo.scrollFactor.set(0.4, 0.4);
		                  add(bgLimo);

		                  grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
		                  add(grpLimoDancers);

		                  for (i in 0...5)
		                  {
		                          var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
		                          dancer.scrollFactor.set(0.4, 0.4);
		                          grpLimoDancers.add(dancer);
		                  }

		                  var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay'));
		                  overlayShit.alpha = 0.5;
		                  // add(overlayShit);

		                  // var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);

		                  // FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);

		                  // overlayShit.shader = shaderBullshit;

		                  var limoTex = Paths.getSparrowAtlas('limo/limoDrive');

		                  limo = new FlxSprite(-120, 550);
		                  limo.frames = limoTex;
		                  limo.animation.addByPrefix('drive', "Limo stage", 24);
		                  limo.animation.play('drive');
		                  limo.antialiasing = true;

		                  fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol'));
		                  // add(limo);
			}
			case 'milf':
			{
					curStage = 'limo';
					defaultCamZoom = 0.90;

					var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset'));
					skyBG.scrollFactor.set(0.1, 0.1);
					add(skyBG);

					var bgLimo:FlxSprite = new FlxSprite(-200, 480);
					bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo');
					bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
					bgLimo.animation.play('drive');
					bgLimo.scrollFactor.set(0.4, 0.4);
					add(bgLimo);

					grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
					add(grpLimoDancers);

					for (i in 0...5)
					{
							var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
							dancer.scrollFactor.set(0.4, 0.4);
							grpLimoDancers.add(dancer);
					}

					var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay'));
					overlayShit.alpha = 0.5;
					// add(overlayShit);

					// var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);

					// FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);

					// overlayShit.shader = shaderBullshit;

					var limoTex = Paths.getSparrowAtlas('limo/limoDrive');

					limo = new FlxSprite(-120, 550);
					limo.frames = limoTex;
					limo.animation.addByPrefix('drive', "Limo stage", 24);
					limo.animation.play('drive');
					limo.antialiasing = true;

					fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol'));
					// add(limo);
					//Alert!
					kb_attack_alert = new FlxSprite();
					kb_attack_alert.frames = Paths.getSparrowAtlas('bonus/attack_alert_NEW_with_EXTRAS');
					kb_attack_alert.animation.addByPrefix('alert', 'kb_attack_animation_alert-single', 24, false);	
					kb_attack_alert.animation.addByPrefix('alertDOUBLE', 'kb_attack_animation_alert-double', 24, false);	
					kb_attack_alert.antialiasing = true;
					kb_attack_alert.setGraphicSize(Std.int(kb_attack_alert.width * 1.5));
					kb_attack_alert.cameras = [camHUD];
					kb_attack_alert.x = FlxG.width - 700;
					kb_attack_alert.y = 205;
					//kb_attack_alert.animation.play("alert"); //Placeholder, change this to start already hidden or whatever.

					//Saw that one coming!
					kb_attack_saw = new FlxSprite();
					kb_attack_saw.frames = Paths.getSparrowAtlas('bonus/attackv6');
					kb_attack_saw.animation.addByPrefix('fire', 'kb_attack_animation_fire', 24, false);	
					kb_attack_saw.animation.addByPrefix('prepare', 'kb_attack_animation_prepare', 24, false);	
					kb_attack_saw.setGraphicSize(Std.int(kb_attack_saw.width * 1.15));
					kb_attack_saw.antialiasing = true;
					kb_attack_saw.setPosition(-860,615);
					kb_attack_saw.x += 200;
					kb_attack_saw.y -= 270;
		          }
		          case 'cocoa' | 'eggnog':
		          {
	                          curStage = 'mall';

		                  defaultCamZoom = 0.80;

		                  var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls'));
		                  bg.antialiasing = true;
		                  bg.scrollFactor.set(0.2, 0.2);
		                  bg.active = false;
		                  bg.setGraphicSize(Std.int(bg.width * 0.8));
		                  bg.updateHitbox();
		                  add(bg);

		                  upperBoppers = new FlxSprite(-240, -90);
		                  upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop');
		                  upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
		                  upperBoppers.antialiasing = true;
		                  upperBoppers.scrollFactor.set(0.33, 0.33);
		                  upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
		                  upperBoppers.updateHitbox();
		                  add(upperBoppers);

		                  var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator'));
		                  bgEscalator.antialiasing = true;
		                  bgEscalator.scrollFactor.set(0.3, 0.3);
		                  bgEscalator.active = false;
		                  bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
		                  bgEscalator.updateHitbox();
		                  add(bgEscalator);

		                  var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree'));
		                  tree.antialiasing = true;
		                  tree.scrollFactor.set(0.40, 0.40);
		                  add(tree);

		                  bottomBoppers = new FlxSprite(-300, 140);
		                  bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop');
		                  bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
		                  bottomBoppers.antialiasing = true;
	                          bottomBoppers.scrollFactor.set(0.9, 0.9);
	                          bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
		                  bottomBoppers.updateHitbox();
		                  add(bottomBoppers);

		                  var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow'));
		                  fgSnow.active = false;
		                  fgSnow.antialiasing = true;
		                  add(fgSnow);

		                  santa = new FlxSprite(-840, 150);
		                  santa.frames = Paths.getSparrowAtlas('christmas/santa');
		                  santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
		                  santa.antialiasing = true;
		                  add(santa);
		          }
		          case 'winter-horrorland':
		          {
		                  curStage = 'mallEvil';
		                  var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG'));
		                  bg.antialiasing = true;
		                  bg.scrollFactor.set(0.2, 0.2);
		                  bg.active = false;
		                  bg.setGraphicSize(Std.int(bg.width * 0.8));
		                  bg.updateHitbox();
		                  add(bg);

		                  var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree'));
		                  evilTree.antialiasing = true;
		                  evilTree.scrollFactor.set(0.2, 0.2);
		                  add(evilTree);

		                  var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow"));
	                          evilSnow.antialiasing = true;
		                  add(evilSnow);
                        }
		          case 'senpai' | 'roses':
		          {
		                  curStage = 'school';

		                  // defaultCamZoom = 0.9;

		                  var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky'));
		                  bgSky.scrollFactor.set(0.1, 0.1);
		                  add(bgSky);

		                  var repositionShit = -200;

		                  var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool'));
		                  bgSchool.scrollFactor.set(0.6, 0.90);
		                  add(bgSchool);

		                  var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet'));
		                  bgStreet.scrollFactor.set(0.95, 0.95);
		                  add(bgStreet);

		                  var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack'));
		                  fgTrees.scrollFactor.set(0.9, 0.9);
		                  add(fgTrees);

		                  var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
		                  var treetex = Paths.getPackerAtlas('weeb/weebTrees');
		                  bgTrees.frames = treetex;
		                  bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
		                  bgTrees.animation.play('treeLoop');
		                  bgTrees.scrollFactor.set(0.85, 0.85);
		                  add(bgTrees);

		                  var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
		                  treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals');
		                  treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
		                  treeLeaves.animation.play('leaves');
		                  treeLeaves.scrollFactor.set(0.85, 0.85);
		                  add(treeLeaves);

		                  var widShit = Std.int(bgSky.width * 6);

		                  bgSky.setGraphicSize(widShit);
		                  bgSchool.setGraphicSize(widShit);
		                  bgStreet.setGraphicSize(widShit);
		                  bgTrees.setGraphicSize(Std.int(widShit * 1.4));
		                  fgTrees.setGraphicSize(Std.int(widShit * 0.8));
		                  treeLeaves.setGraphicSize(widShit);

		                  fgTrees.updateHitbox();
		                  bgSky.updateHitbox();
		                  bgSchool.updateHitbox();
		                  bgStreet.updateHitbox();
		                  bgTrees.updateHitbox();
		                  treeLeaves.updateHitbox();

		                  bgGirls = new BackgroundGirls(-100, 190);
		                  bgGirls.scrollFactor.set(0.9, 0.9);

		                  if (SONG.song.toLowerCase() == 'roses')
	                          {
		                          bgGirls.getScared();
		                  }

		                  bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
		                  bgGirls.updateHitbox();
		                  add(bgGirls);
		          }
		          case 'thorns':
		          {
		                  curStage = 'schoolEvil';

		                  var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
		                  var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);

		                  var posX = 400;
	                          var posY = 200;

		                  var bg:FlxSprite = new FlxSprite(posX, posY);
		                  bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool');
		                  bg.animation.addByPrefix('idle', 'background 2', 24);
		                  bg.animation.play('idle');
		                  bg.scrollFactor.set(0.8, 0.9);
		                  bg.scale.set(6, 6);
		                  add(bg);

		                  /* 
		                           var bg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolBG'));
		                           bg.scale.set(6, 6);
		                           // bg.setGraphicSize(Std.int(bg.width * 6));
		                           // bg.updateHitbox();
		                           add(bg);

		                           var fg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolFG'));
		                           fg.scale.set(6, 6);
		                           // fg.setGraphicSize(Std.int(fg.width * 6));
		                           // fg.updateHitbox();
		                           add(fg);

		                           wiggleShit.effectType = WiggleEffectType.DREAMY;
		                           wiggleShit.waveAmplitude = 0.01;
		                           wiggleShit.waveFrequency = 60;
		                           wiggleShit.waveSpeed = 0.8;
		                    */

		                  // bg.shader = wiggleShit.shader;
		                  // fg.shader = wiggleShit.shader;

		                  /* 
		                            var waveSprite = new FlxEffectSprite(bg, [waveEffectBG]);
		                            var waveSpriteFG = new FlxEffectSprite(fg, [waveEffectFG]);

		                            // Using scale since setGraphicSize() doesnt work???
		                            waveSprite.scale.set(6, 6);
		                            waveSpriteFG.scale.set(6, 6);
		                            waveSprite.setPosition(posX, posY);
		                            waveSpriteFG.setPosition(posX, posY);

		                            waveSprite.scrollFactor.set(0.7, 0.8);
		                            waveSpriteFG.scrollFactor.set(0.9, 0.8);

		                            // waveSprite.setGraphicSize(Std.int(waveSprite.width * 6));
		                            // waveSprite.updateHitbox();
		                            // waveSpriteFG.setGraphicSize(Std.int(fg.width * 6));
		                            // waveSpriteFG.updateHitbox();

		                            add(waveSprite);
		                            add(waveSpriteFG);
		                    */
		          }
		          default:
		          {
		                  defaultCamZoom = 0.9;
		                  curStage = 'stage';
		                  var bg:BGSprite = new BGSprite("stageback", -600, -200, 0.9, 0.9);
		                  add(bg);

		                  var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
		                  stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		                  stageFront.updateHitbox();
		                  stageFront.antialiasing = true;
		                  stageFront.scrollFactor.set(0.9, 0.9);
		                  stageFront.active = false;
		                  add(stageFront);

		                  var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
		                  stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
		                  stageCurtains.updateHitbox();
		                  stageCurtains.antialiasing = true;
		                  stageCurtains.scrollFactor.set(1.3, 1.3);
		                  stageCurtains.active = false;

		                  add(stageCurtains);
		          }
              }

		var gfVersion:String = 'gf';

		switch (curStage)
		{
			case 'limo':
				gfVersion = 'gf-car';
			case 'mall' | 'mallEvil':
				gfVersion = 'gf-christmas';
			case 'school':
				gfVersion = 'gf-pixel';
			case 'schoolEvil':
				gfVersion = 'gf-pixel';
		}

		if (curStage == 'limo')
			gfVersion = 'gf-car';

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);

		dad = new Character(100, 100, SONG.player2);



		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}

			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 100;
			case 'monster-christmas':
				dad.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;

				resetFastCar();
				add(fastCar);

			case 'mall':
				boyfriend.x += 200;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				// trailArea.scrollFactor.set();

				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				// evilTrail.changeValuesEnabled(false, false, false, false);
				// evilTrail.changeGraphic()
				add(evilTrail);
				// evilTrail.scrollFactor.set(1.1, 1.1);

				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'streetFinal' | 'streetCute' | 'street' :
				boyfriend.x += 40;
				boyfriend.y += 65;
				if(SONG.song.toLowerCase() == 'censory-overload' || SONG.song.toLowerCase() == 'termination' || SONG.song.toLowerCase() == 'extermination' || SONG.song.toLowerCase() == 'expurgation'){
					dad.x -= 70;
					dad.y += 66;
					if(!Main.qtOptimisation){
						boyfriend404.x += 40;
						boyfriend404.y += 65;
						dad404.x -= 70;
						dad404.y += 66;
					}
				}else if(SONG.song.toLowerCase() == 'terminate' || SONG.song.toLowerCase() == 'cessation'){
					dad.x -= 70;
					dad.y += 65;
				}
				
		}

		add(gf);

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		add(dad);
		add(boyfriend);
		
		if(curStage == "nightmare"){
			dad.alpha=0;
			gf.alpha=0;
			add(boyfriend404);
		}
		
		if(SONG.song.toLowerCase() == 'censory-overload' || SONG.song.toLowerCase() == 'termination' || SONG.song.toLowerCase() == 'extermination' || SONG.song.toLowerCase() == 'expurgation'){
			add(gf404);
			add(boyfriend404);
			add(dad404);
		}

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		var bgForNotes1:FlxSprite = new FlxSprite(40 + 50, 0).makeGraphic(470, FlxG.height);
		bgForNotes1.scrollFactor.set();
		bgForNotes1.screenCenter(Y);
		var bgForNotes2:FlxSprite = new FlxSprite(680 + 50, 0).makeGraphic(470, FlxG.height);
		bgForNotes2.scrollFactor.set();
		bgForNotes2.screenCenter(Y);
		bgForNotes2.color = FlxColor.BLACK;
		bgForNotes1.color = FlxColor.BLACK;
		bgForNotes1.alpha = 0.4;
		bgForNotes2.alpha = 0.4;

		var bgForNotes12:FlxSprite = new FlxSprite(30 + 50, 0).makeGraphic(490, FlxG.height);
		bgForNotes12.scrollFactor.set();
		bgForNotes12.screenCenter(Y);
		var bgForNotes22:FlxSprite = new FlxSprite(670 + 50, 0).makeGraphic(490, FlxG.height);
		bgForNotes22.scrollFactor.set();
		bgForNotes22.screenCenter(Y);
		bgForNotes22.color = FlxColor.BLACK;
		bgForNotes12.color = FlxColor.BLACK;
		bgForNotes12.alpha = 0.4;
		bgForNotes22.alpha = 0.4;

		if(FlxG.save.data.middlescroll)
		{
			bgForNotes2.alpha = 0.2;
			bgForNotes1.alpha = 0.2;
			bgForNotes2.x = 360 + 50;
			bgForNotes1.x = 360 + 50;

			bgForNotes22.alpha = 0.2;
			bgForNotes12.alpha = 0.2;
			bgForNotes22.x = 350 + 50;
			bgForNotes12.x = 350 + 50;
		}


		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();
		strumLine.screenCenter(X);
		timeTxt = new FlxText(strumLine.x + (FlxG.width / 2) - 245 + 50, strumLine.y - 40, 400, "0:00", 30);
		timeTxt.setFormat(Paths.font("vcr.ttf"), 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0.5;
		timeTxt.borderSize = 1.25;


		if (FlxG.save.data.downscroll)
		{
			timeTxt.y = FlxG.height - 45;
			strumLine.y = FlxG.height - 150;
		}

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		
		if(FlxG.save.data.bgNotes)
		{
			add(bgForNotes1);
			add(bgForNotes2);
			add(bgForNotes12);
			add(bgForNotes22);
		}
		add(timeTxt);
		add(strumLineNotes);

		add(grpNoteSplashes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		dadStrums = new FlxTypedGroup<FlxSprite>();

		// startCountdown();

		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		if (FlxG.save.data.downscroll)
			healthBarBG.y = FlxG.height * 0.1;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);



		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		var p1ColorBar:FlxColor = new FlxColor();
		var p2ColorBar:FlxColor = new FlxColor();

		switch (SONG.player1) 
		{
			case 'bf' | 'bf-car' | 'bf-christmas':
			{
				p1ColorBar.setRGB(49, 176, 209, 255);
			}
			case 'bf-pixel':
			{
				p1ColorBar.setRGB(123, 214, 246, 255);
			}
			case 'gf' | 'gf-pixel' | 'gf-christmas':
			{
				p1ColorBar.setRGB(165, 0, 77, 255);
			}
			case 'monster' | 'monster-christmas':
			{
				p1ColorBar.setRGB(243, 255, 110, 255);
			}
			case 'parents-christmas':
			{
				p1ColorBar.setRGB(188, 95, 183, 255);
			}
			case 'dad':
			{
				p1ColorBar.setRGB(175, 102, 206, 255);
			}
			case 'mom' | 'mom-car':
			{
				p1ColorBar.setRGB(216, 85, 142, 255);
			}
			case 'tankman':
			{
				p1ColorBar.setRGB(127, 127, 127, 255);
			}
			case 'face':
			{
				p1ColorBar.setRGB(161, 161, 161, 255);
			}
			case 'bf-old':
			{
				p1ColorBar.setRGB(233, 255, 72, 255);
			}
			case 'spirit':
			{
				p1ColorBar.setRGB(255, 60, 110, 255);
			}
			case 'senpai' | 'senpai-angry':
			{
				p1ColorBar.setRGB(255, 170, 111, 255);
			}
			case 'pico':
			{
				p1ColorBar.setRGB(183, 216, 85, 255);
			}
			case 'spooky':
			{
				p1ColorBar.setRGB(213, 126, 0, 255);
			}
			default:
			{
				p1ColorBar.setRGB(255, 0, 0, 255);
			}
		}

		switch (SONG.player2) 
		{
			case 'bf' | 'bf-car' | 'bf-christmas':
			{
				p2ColorBar.setRGB(49, 176, 209, 255);
			}
			case 'bf-pixel':
			{
				p2ColorBar.setRGB(123, 214, 246, 255);
			}
			case 'gf' | 'gf-pixel' | 'gf-christmas':
			{
				p2ColorBar.setRGB(165, 0, 77, 255);
			}
			case 'monster' | 'monster-christmas':
			{
				p2ColorBar.setRGB(243, 255, 110, 255);
			}
			case 'parents-christmas':
			{
				p2ColorBar.setRGB(188, 95, 183, 255);
			}
			case 'dad':
			{
				p2ColorBar.setRGB(175, 102, 206, 255);
			}
			case 'mom' | 'mom-car':
			{
				p2ColorBar.setRGB(216, 85, 142, 255);
			}
			case 'tankman':
			{
				p2ColorBar.setRGB(127, 127, 127, 255);
			}
			case 'face':
			{
				p2ColorBar.setRGB(161, 161, 161, 255);
			}
			case 'bf-old':
			{
				p2ColorBar.setRGB(233, 255, 72, 255);
			}
			case 'spirit':
			{
				p2ColorBar.setRGB(255, 60, 110, 255);
			}
			case 'senpai' | 'senpai-angry':
			{
				p2ColorBar.setRGB(255, 170, 111, 255);
			}
			case 'pico':
			{
				p2ColorBar.setRGB(183, 216, 85, 255);
			}
			case 'spooky':
			{
				p2ColorBar.setRGB(213, 126, 0, 255);
			}
			default:
			{
				p2ColorBar.setRGB(255, 0, 0, 255);
			}
		}
		
		healthBar.createFilledBar(p2ColorBar, p1ColorBar);
		add(healthBar);

		scoreTxt = new FlxText(healthBarBG.x + 50, healthBarBG.y + 45, 0, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		add(scoreTxt);


		if(FlxG.save.data.botAutoPlay)
		{
			botAutoPlayAlert = new FlxText(0, 500, 0, "BOT AUTO PLAY", 40);
			botAutoPlayAlert.screenCenter(X);
			botAutoPlayAlert.setFormat(Paths.font("vcr.ttf"), 38, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			botAutoPlayAlert.scrollFactor.set();
			add(botAutoPlayAlert);
		}
		

		

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		bgForNotes1.cameras = [camHUD];
		bgForNotes2.cameras = [camHUD];
		bgForNotes12.cameras = [camHUD];
		bgForNotes22.cameras = [camHUD];
		if(FlxG.save.data.botAutoPlay)
			botAutoPlayAlert.cameras = [camHUD];
		
		doof.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		
                #if android
	        addAndroidControls();
                #end
                
                if (SONG.song.toLowerCase() == "termination" || SONG.song.toLowerCase()=='tutorial' || SONG.song.toLowerCase() == 'extermination' || SONG.song.toLowerCase()=='milf' || SONG.song.toLowerCase()=='expurgation') {
		    addVirtualPad(NONE, A);
		    addPadCamera();
		}

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		if (isStoryMode && !seenCutscene)
		{
			PlayState.seenCutscene = true;
			switch (curSong.toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				case 'senpai':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				case 'thorns':
					schoolIntro(doof);
				case 'carefree' | 'careless' | 'terminate':
					schoolIntro(doof);
				case 'censory-overload':
					schoolIntro(doof);
				default:
					startCountdown();
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				default:
					startCountdown();
			}
		}

		super.create();
	}


	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-300, -100).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
		black.scrollFactor.set();

		FlxG.log.notice(qtCarelessFin);
		if(!qtCarelessFin)
		{
			add(black);
		}
		else
		{
			FlxTween.tween(FlxG.camera, {x: 0, y:0}, 1.5, {
				ease: FlxEase.quadInOut
			});
		}

		trace(cutsceneSkip);
		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		var horrorStage:FlxSprite = new FlxSprite();
		if(!cutsceneSkip){
			if(SONG.song.toLowerCase() == 'censory-overload'){
				camHUD.visible = false;
				//BG
				horrorStage.frames = Paths.getSparrowAtlas('stage/horrorbg');
				horrorStage.animation.addByPrefix('idle', 'Symbol 10 instance ', 24, false);
				horrorStage.antialiasing = true;
				horrorStage.scrollFactor.set();
				horrorStage.screenCenter();

				//QT sprite
				senpaiEvil.frames = Paths.getSparrowAtlas('cutscenev3');
				senpaiEvil.animation.addByPrefix('idle', 'final_edited', 24, false);
				senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 0.875));
				senpaiEvil.scrollFactor.set();
				senpaiEvil.updateHitbox();
				senpaiEvil.screenCenter();
				senpaiEvil.x -= 140;
				senpaiEvil.y -= 55;
			}else{
				senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
				senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
				senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
				senpaiEvil.scrollFactor.set();
				senpaiEvil.updateHitbox();
				senpaiEvil.screenCenter();
			}
		}
		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
			}
		}
		else if (SONG.song.toLowerCase() == 'censory-overload' && !cutsceneSkip)
		{
			add(horrorStage);
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'censory-overload' && !cutsceneSkip)
					{
						//Background old
						//var horrorStage:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stage/horrorbg'));
						//horrorStage.antialiasing = true;
						//horrorStage.scrollFactor.set();
						//horrorStage.y-=125;
						//add(horrorStage);
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								horrorStage.animation.play('idle');
								FlxG.sound.play(Paths.sound('music-box-horror'), 0.9, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									remove(horrorStage);
									camHUD.visible = true;
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(13, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 3, false);
								});
							}
						});
					}
					else if (SONG.song.toLowerCase() == 'thorns'  && !cutsceneSkip)
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					if(!qtCarelessFin)
					{
						startCountdown();
					}
					else
					{
						loadSongHazard();
					}

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	function startCountdown():Void
	{
		inCutscene = false;

	        #if android
	        androidc.visible = true;
	        #end
		generateStaticArrowsDAD();
		generateStaticArrowsBF();
		if(curStage == "nightmare"){
			remove(vignette); //update layering?
			add(vignette);
			vignette.cameras = [camHUD];
		}

		
		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			if(!Main.qtOptimisation && (SONG.song.toLowerCase()=='censory-overload' || SONG.song.toLowerCase() == 'termination' || SONG.song.toLowerCase() == 'extermination' || SONG.song.toLowerCase() == 'expurgation')){
				dad404.dance();
				gf404.dance();
				boyfriend404.playAnim('idle');
			}
			dad.dance();
			gf.dance();
			boyfriend.dance();

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
			introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3'), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2'), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1'), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo'), 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}
	function startFakeCountdown(withSound:Bool):Void
	{

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
			introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)

			{
				case 0:
					if(withSound)FlxG.sound.play(Paths.sound('intro3'), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					if(withSound)FlxG.sound.play(Paths.sound('intro2'), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					if(withSound)FlxG.sound.play(Paths.sound('intro1'), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					if(withSound)FlxG.sound.play(Paths.sound('introGo'), 0.6);
				case 4:
			}

			swagCounter += 1;
		}, 5);
	}
	
	var grabbed = false;

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;
		
		bfCanDodge = true;
		hazardRandom = FlxG.random.int(1, 5);

		if (!paused)
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = endSong;
		vocals.play();
		FlxTween.tween(timeTxt, {alpha: 1}, 1, {ease: FlxEase.circOut});

		#if windows
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") ", "Misses:" + misses + " | " + "Score:" + songScore + " | " + "KPS:" + kps + "(" + kpsMax + ")" + " | " + "Accuracy:" + totalAccuracy + "%" + " | " + "Rank:" + totalRank, iconRPC);
		#end

		

	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);
				var daRandomNoteData:Int = FlxG.random.int(0,3);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, (!randomNotes ? daNoteData : daRandomNoteData), oldNote, false, (!gottaHitNote ? dad.noteSkin : ""));
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);
				swagNote.altNote = songNotes[3];

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, (!randomNotes ? daNoteData : daRandomNoteData), oldNote, true, (!gottaHitNote ? dad.noteSkin : ""));
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if(sustainNote.mustPress)
					{
						if(!FlxG.save.data.middlescroll)
							sustainNote.x += ((FlxG.width / 2) * 1) + 50;
						else
							sustainNote.x += ((FlxG.width / 2) * 0.5) + 50;
					}
					else
					{
						if(!FlxG.save.data.middlescroll)
							sustainNote.x += ((FlxG.width / 2) * 0) + 50;
						else
							sustainNote.x += ((FlxG.width / 2) * 0.5) + 50;
					}
					if(gottaHitNote == false && FlxG.save.data.middlescroll)
						sustainNote.alpha = 0.2;
				}

				swagNote.mustPress = gottaHitNote;

				if(gottaHitNote == false && FlxG.save.data.middlescroll)
					swagNote.alpha = 0.35;

				if(swagNote.mustPress)
				{
					if(!FlxG.save.data.middlescroll)
						swagNote.x += ((FlxG.width / 2) * 1) + 50;
					else
						swagNote.x += ((FlxG.width / 2) * 0.5) + 50;
				}
				else
				{
					if(!FlxG.save.data.middlescroll)
						swagNote.x += ((FlxG.width / 2) * 0) + 50;
					else
						swagNote.x += ((FlxG.width / 2) * 0.5) + 50;
				}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrowsBF():Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			switch (curStage)
			{
				case 'school' | 'schoolEvil':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
					}

				default:
					babyArrow.frames = Paths.getSparrowAtlas("NOTE_assets");
					babyArrow.animation.addByPrefix('green', 'arrowUP', 24, true);
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN', 24, true);
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT', 24, true);
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT', 24, true);

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrowLEFT', 24, true);
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);

						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrowDOWN', 24, true);
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);

						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrowUP', 24, true);
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);

						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT', 24, true);
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);

					}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			else
			{
				FlxG.save.data.downscroll ? babyArrow.y += 100 : babyArrow.y -= 100;
				babyArrow.alpha = 0.4;
				FlxTween.tween(babyArrow, {y: FlxG.save.data.downscroll ? babyArrow.y - 100 : babyArrow.y + 100, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.6 + (0.15 * i)});
			}

			babyArrow.ID = i;

			playerStrums.add(babyArrow);
			
			babyArrow.animation.play('static');
			babyArrow.x += 50;
			if(!FlxG.save.data.middlescroll)
				babyArrow.x += ((FlxG.width / 2) * 1) + 50;
			else
				babyArrow.x += ((FlxG.width / 2) * 0.5) + 50;

			strumLineNotes.add(babyArrow);
		}
	}

	private function generateStaticArrowsDAD():Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			switch (curStage)
			{
				case 'school' | 'schoolEvil':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
					}

				default:
					babyArrow.frames = Paths.getSparrowAtlas((dad.noteSkin != "" ? dad.noteSkin : "NOTE_assets"));
					babyArrow.animation.addByPrefix('green', 'arrowUP', 24, true);
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN', 24, true);
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT', 24, true);
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT', 24, true);

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrowLEFT', 24, true);
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);

						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrowDOWN', 24, true);
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);

						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrowUP', 24, true);
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);

						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT', 24, true);
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);

					}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if(FlxG.save.data.middlescroll)
				babyArrow.alpha = 0;

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				if(!FlxG.save.data.middlescroll)
					FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			

			babyArrow.ID = i;

			dadStrums.add(babyArrow);
			
			babyArrow.animation.play('static');
			babyArrow.x += 50;
			if(!FlxG.save.data.middlescroll)
				babyArrow.x += ((FlxG.width / 2) * 0) + 50;
			else
				babyArrow.x += ((FlxG.width / 2) * 0.5) + 50;

			strumLineNotes.add(babyArrow);
		}
	}
	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}
			#if windows
			DiscordClient.changePresence("PAUSED on " + SONG.song + " (" + storyDifficultyText + ") ", "Misses:" + misses + " | " + "Score:" + songScore + " | " + "KPS:" + kps + "(" + kpsMax + ")" + " | " + "Accuracy:" + totalAccuracy + "%" + " | " + "Rank:" + totalRank, iconRPC);
			#end

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if windows
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") ", "Misses:" + misses + " | " + "Score:" + songScore + " | " + "KPS:" + kps + "(" + kpsMax + ")" + " | " + "Accuracy:" + totalAccuracy + "%" + " | " + "Rank:" + totalRank, iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ") ", iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
		}
		#end

		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();

		#if windows
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") ", "Misses:" + misses + " | " + "Score:" + songScore + " | " + "KPS:" + kps + "(" + kpsMax + ")" + " | " + "Accuracy:" + totalAccuracy + "%" + " | " + "Rank:" + totalRank, iconRPC);
		#end
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end

		time += elapsed;
		CalculateKeysPerSecond();
		if(kps >= kpsMax)
			kpsMax = kps;

		if (FlxG.keys.justPressed.NINE)
		{
			/*if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');*/
			iconP1.swapOldIcon();
		}

		switch (curStage)
		{
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
		}



		
		
		super.update(elapsed);

		FlxG.camera.followLerp = CoolUtil.camLerpShit(0.04);

		if(totalAccuracy >= maxTotalAccuracy)
			maxTotalAccuracy = totalAccuracy;
		if(combo >= maxCombo)
			maxCombo = combo;


		if(spinCamHud)
		{
			spinHudCamera();
		}
		if(spinCamGame)
		{
			spinGameCamera();
		}
		if(spinPlayerNotes)
		{
			spinPlayerStrumLineNotes();
		}
		if(spinEnemyNotes)
		{
			spinEnemyStrumLineNotes();
		}

		

		if(FlxG.save.data.shadersOn)
		{
			if (chromOn)
			{
				ch = FlxG.random.int(1,5) / 1000;
				ch = FlxG.random.int(1,5) / 1000;
				Shaders.setChrome(ch);
			}
			else
			{
				Shaders.setChrome(0);
			}

			if (vignetteOn)
			{
				Shaders.setVignette(vignetteRadius);
			}
			else
			{
				Shaders.setVignette(0);
			}

		}
		

		

		


		// ranking system
		if(totalAccuracy == 100)
		{
			totalRank = "S++";
		}
		else if(totalAccuracy < 100 && totalAccuracy >= 95)
		{
			totalRank = "S+";
		}
		else if(totalAccuracy < 95 && totalAccuracy >= 90)
		{
			totalRank = "S";
		}
		else if(totalAccuracy < 90 && totalAccuracy >= 85)
		{
			totalRank = "S-";
		}
		else if(totalAccuracy < 85 && totalAccuracy >= 70)
		{
			totalRank = "A";
		}
		else if(totalAccuracy < 70 && totalAccuracy >= 60)
		{
			totalRank = "B";
		}
		else if(totalAccuracy < 60 && totalAccuracy >= 40)
		{
			totalRank = "C";
		}
		else if(totalAccuracy < 40 && totalAccuracy >= 20)
		{
			totalRank = "D";
		}
		else if(totalAccuracy < 20 && totalAccuracy >= 0)
		{
			totalRank = "F";
		}



		if(instaFail == true && misses >= 1)
		{
			health = 0;
		}



		if(misses == 0 && songNotesHit == 0)
			totalAccuracy = 0;
		else if(songNotesHit == 0)
			totalAccuracy = 0;
		else
			totalAccuracy = FlxMath.roundDecimal((songNotesHit / (songNotesHit + misses) * 100), 2);

		
		if(songNotesHit == misses)
			totalAccuracy = 0;
		
		scoreTxt.text = "Misses:" + misses + " | " + "Score:" + songScore + " | " + "KPS:" + kps + "(" + kpsMax + ")" + " | " + "Accuracy:" + totalAccuracy + "%" + " | " + "Rank:" + totalRank;
		

		if (FlxG.keys.justPressed.ENTER #if android || FlxG.android.justReleased.BACK #end && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				// gitaroo man easter egg
				FlxG.switchState(new GitarooPause());
			}
			else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		
			#if desktop
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			FlxG.switchState(new ChartingState());

			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(150 + 0.85 * (iconP1.width - 150)));
                iconP2.setGraphicSize(Std.int(150 + 0.85 * (iconP2.width - 150)));

                if(iconP1.angle < 0)
                	iconP1.angle = CoolUtil.coolLerp(iconP1.angle, 0, Conductor.crochet / 1000 / cameraBeatSpeed);
                if(iconP2.angle > 0)
                	iconP2.angle = CoolUtil.coolLerp(iconP2.angle, 0, Conductor.crochet / 1000 / cameraBeatSpeed);

                if(iconP1.angle > 0)
                	iconP1.angle = 0;
                if(iconP2.angle < 0)
                	iconP2.angle = 0;

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
		{
			//FlxColor.fromRGB(255, 64, 64)
			scoreTxt.color = CoolUtil.smoothColorChange(scoreTxt.color, FlxColor.fromRGB(255, 64, 64), 0.3);
			iconP1.animation.curAnim.curFrame = 1;
			if(iconP2.animation.curAnim.numFrames == 3)
				iconP2.animation.curAnim.curFrame = 2;
		}
		else if (healthBar.percent > 80)
		{
			//FlxColor.fromRGB(100, 255, 100)
			scoreTxt.color = CoolUtil.smoothColorChange(scoreTxt.color, FlxColor.fromRGB(100, 255, 100), 0.3);
			iconP2.animation.curAnim.curFrame = 1;
			if(iconP1.animation.curAnim.numFrames == 3)
				iconP1.animation.curAnim.curFrame = 2;
		}
		else
		{
			iconP1.animation.curAnim.curFrame = 0;
			iconP2.animation.curAnim.curFrame = 0;
			scoreTxt.color = CoolUtil.smoothColorChange(scoreTxt.color, FlxColor.fromRGB(255, 255, 255), 0.3);
		}
			

		
		

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		#if debug
		if (FlxG.keys.justPressed.EIGHT)
			FlxG.switchState(new AnimationDebug(SONG.player2));
		#end

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
				var curTime:Float = FlxG.sound.music.time;
				if(curTime < 0) curTime = 0;
				//songPercent = (curTime / songLength);
				var secondsTotal:Int = Math.floor((FlxG.sound.music.length - curTime) / 1000);
				if(secondsTotal < 0) secondsTotal = 0;
				var minutesRemaining:Int = Math.floor(secondsTotal / 60);
				var secondsRemaining:String = '' + secondsTotal % 60;
				if(secondsRemaining.length < 2) secondsRemaining = '0' + secondsRemaining; //Dunno how to make it display a zero first in Haxe lol
				timeTxt.text = minutesRemaining + ':' + secondsRemaining;
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}

			if (/*camFollow.x != dad.getMidpoint().x + 150 && */!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				var camFollowX:Float = dad.getMidpoint().x;
				var camFollowY:Float = dad.getMidpoint().y;

				switch (dad.curCharacter)
				{
					case 'mom':
						camFollowY = dad.getMidpoint().y;
					case 'senpai':
						camFollowY = dad.getMidpoint().y - 400;
						camFollowX = dad.getMidpoint().x - 250;
					case 'senpai-angry':
						camFollowY = dad.getMidpoint().y - 400;
						camFollowX = dad.getMidpoint().x - 250;
					case 'qt' | 'qt_annoyed':
						camFollow.y = dad.getMidpoint().y + 261;
					case 'qt_classic':
						camFollow.y = dad.getMidpoint().y + 95;
					case 'robot' | 'robot_404' | 'robot_angry' | 'robot_404-TERMINATION' | 'robot_classic' | 'robot_classic_404':
						camFollow.y = dad.getMidpoint().y + 25;
						camFollow.x = dad.getMidpoint().x - 18;
					case 'qt-kb':
						camFollow.y = dad.getMidpoint().y + 25;
						camFollow.x = dad.getMidpoint().x - 18;
					case 'qt-meme':
						camFollow.y = dad.getMidpoint().y + 107;
					case 'pico':
						camFollowY = dad.getMidpoint().y;
					default:
						camFollowX = dad.getMidpoint().x;
						camFollowY = dad.getMidpoint().y;
						if(dad.animation.curAnim.name.startsWith("singLEFT")){
							camFollowX = camFollowX - 20;
						}
						if(dad.animation.curAnim.name.startsWith("singRIGHT")){
							camFollowX = camFollowX + 20;
						}
						if(dad.animation.curAnim.name.startsWith("singUP")){
							camFollowY = camFollowY - 20;
						}
						if(dad.animation.curAnim.name.startsWith("singDOWN")){
							camFollowY = camFollowY + 20;
						}
				}

				
				camFollow.setPosition(camFollowX + 150, camFollowY - 100);

				if (dad.curCharacter == 'mom')
					vocals.volume = 1;

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					tweenCamIn();
				}
			}

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection/* && camFollow.x != boyfriend.getMidpoint().x - 100*/)
			{
				var camFollowX:Float = boyfriend.getMidpoint().x;
				var camFollowY:Float = boyfriend.getMidpoint().y;
				

				switch (curStage)
				{
					case 'limo':
						camFollowX = boyfriend.getMidpoint().x - 200;
					case 'mall':
						camFollowY = boyfriend.getMidpoint().y - 100;
					case 'school':
						camFollowX = boyfriend.getMidpoint().x - 100;
						camFollowY = boyfriend.getMidpoint().y - 100;
					case 'schoolEvil':
						camFollowX = boyfriend.getMidpoint().x - 100;
						camFollowY = boyfriend.getMidpoint().y - 100;
					case 'philly':
						camFollowX = boyfriend.getMidpoint().x;
					default:
						camFollowX = boyfriend.getMidpoint().x;
						camFollowY = boyfriend.getMidpoint().y;
						if(boyfriend.animation.curAnim.name.startsWith("singLEFT")){
							camFollowX = camFollowX - 20;
						}
						if(boyfriend.animation.curAnim.name.startsWith("singRIGHT")){
							camFollowX = camFollowX + 20;
						}
						if(boyfriend.animation.curAnim.name.startsWith("singUP")){
							camFollowY = camFollowY - 20;
						}
						if(boyfriend.animation.curAnim.name.startsWith("singDOWN")){
							camFollowY = camFollowY + 20;
						}
				}

				

				camFollow.setPosition(camFollowX - 100, camFollowY - 100);

				
				

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
				}
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);
		
		//Mid-Song events for Censory-Overload
		if (curSong.toLowerCase() == 'censory-overload'){
				switch (curBeat)
				{
					case 2:
						if(!Main.qtOptimisation){
							boyfriend404.alpha = 0; 
							dad404.alpha = 0;
							gf404.alpha = 0;
						}
					/*case 4:
						//Experimental stuff
						FlxG.log.notice('Anything different?');
						qtIsBlueScreened = true;
						CensoryOverload404();*/
					case 64:
						qt_tv01.animation.play("eye");
					case 80: //First drop
						gfSpeed = 1;
						qt_tv01.animation.play("idle");
					case 208: //First drop end
						gfSpeed = 2;
					case 240: //2nd drop hype!!!
						qt_tv01.animation.play("drop");
					case 304: //2nd drop
						gfSpeed = 1;
					case 432:  //2nd drop end
						qt_tv01.animation.play("idle");
						gfSpeed = 2;
					case 558: //rawr xd
						FlxG.camera.shake(0.00425,0.6725);
						qt_tv01.animation.play("eye");
					case 560: //3rd drop
						gfSpeed = 1;
						qt_tv01.animation.play("idle");
					case 688: //3rd drop end
						gfSpeed = 2;
					case 702:
						//Change to glitch background
						if(!Main.qtOptimisation){
							streetBGerror.visible = true;
							streetBG.visible = false;
						}
						qt_tv01.animation.play("error");
						FlxG.camera.shake(0.0075,0.67);
					case 704: //404 section
						gfSpeed = 1;
						//Change to bluescreen background
						qt_tv01.animation.play("404");
						if(!Main.qtOptimisation){
							streetBG.visible = false;
							streetBGerror.visible = false;
							streetFrontError.visible = true;
							qtIsBlueScreened = true;
							CensoryOverload404();
						}
					case 832: //Final drop
						//Revert back to normal
						if(!Main.qtOptimisation){
							streetBG.visible = true;
							streetFrontError.visible = false;
							qtIsBlueScreened = false;
							CensoryOverload404();
						}
						gfSpeed = 1;
					case 960: //After final drop. 
						qt_tv01.animation.play("idle");
						//gfSpeed = 2; //Commented out because I like gfSpeed being 1 rather then 2. -Haz
				}
		}
		else if (curSong.toLowerCase() == 'terminate'){ //For finishing the song early or whatever.
			if(curStep == 128){
				dad.playAnim('singLEFT', true);
				if(!qtCarelessFinCalled)
					terminationEndEarly();
			}
		}

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				case 163:
					// FlxG.sound.music.stop();
					// FlxG.switchState(new TitleState());
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}
		// better streaming of shit

		// RESET = Quick Game Over Screen
		if (controls.RESET)
		{
			health = 0;
			trace("RESET = True");
		}

		// CHEAT = brandon's a pussy
		if (controls.CHEAT)
		{
			health += 1;
			trace("User is cheating!");
		}

		if (health <= 0)
		{
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			deathCounter++;
			if(!FlxG.save.data.instRespawn)
				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			else
				FlxG.switchState(new PlayState());

			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			
			#if windows
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("GAME OVER -- " + SONG.song + " (" + storyDifficultyText + ") ","Misses:" + misses + " | " + "Score:" + songScore + " | " + "KPS:" + kps + "(" + kpsMax + ")" + " | " + "Accuracy:" + totalAccuracy + "%" + " | " + "Rank:" + totalRank, iconRPC);
			#end
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				//daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2)));
				var c = strumLine.y + Note.swagWidth / 2;
				if(FlxG.save.data.downscroll)
				{
					daNote.y = strumLine.y + 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2);
					if(daNote.isSustainNote)
					{
						if(daNote.animation.curAnim.name.endsWith("end") && daNote.prevNote != null)
							daNote.y = daNote.y + daNote.prevNote.height;
						else
							daNote.y = daNote.y + daNote.height / 2;

						if( (!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit) && daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= c)
						{
							var d = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
			                                d.height = (c - daNote.y) / daNote.scale.y;
			                                d.y = daNote.frameHeight - d.height;
			                                daNote.clipRect = d;
			                        }
					}
				}
				else
				{
					daNote.y = strumLine.y - 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2);
					if(daNote.isSustainNote)
					{
						if( (!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit) && daNote.y + daNote.offset.y * daNote.scale.y <= c)
						{
							var d = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
				                        d.y = (c - daNote.y) / daNote.scale.y;
				                        d.height -= d.y;
				                        daNote.clipRect = d;
				                }
				        }
				}
				/*if (daNote.isSustainNote
					&& daNote.y + daNote.offset.y <= strumLine.y + Note.swagWidth / 2
					&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
				{
					var swagRect = new FlxRect(0, strumLine.y + Note.swagWidth / 2 - daNote.y, daNote.width * 2, daNote.height * 2);
					swagRect.y /= daNote.scale.y;
					swagRect.height -= swagRect.y;

					daNote.clipRect = swagRect;
				}*/

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					if (SONG.song != 'Tutorial')
						camZooming = true;

					var altAnim:String = "";
					
						if(dad.curCharacter == "qt_annoyed" && FlxG.random.int(1, 17) == 2)
						{
							//Code for QT's random "glitch" alt animation to play.
							altAnim = '-alt';
							
							//Probably a better way of doing this by using the random int and throwing that at the end of the string... but I'm stupid and lazy. -Haz
							switch(FlxG.random.int(1, 3))
							{
								case 2:
									FlxG.sound.play(Paths.sound('glitch-error02'));
								case 3:
									FlxG.sound.play(Paths.sound('glitch-error03'));
								default:
									FlxG.sound.play(Paths.sound('glitch-error01'));
							}

							//18.5% chance of an eye appearing on TV when glitching
							if(curStage == "street" && FlxG.random.bool(18.5)){ 
								if(!(curBeat >= 190 && curStep <= 898)){ //Makes sure the alert animation stuff isn't happening when the TV is playing the alert animation.
									if(FlxG.random.bool(52)) //Randomises whether the eye appears on left or right screen.
										qt_tv01.animation.play('eyeLeft');
									else
										qt_tv01.animation.play('eyeRight');

									qt_tv01.animation.finishCallback = function(pog:String){
										if(qt_tv01.animation.curAnim.name == 'eyeLeft' || qt_tv01.animation.curAnim.name == 'eyeRight'){ //Making sure this only executes for only the eye animation played by the random chance. Probably a better way of doing it, but eh. -Haz
											qt_tv01.animation.play('idle');
										}
									}
								}
							}
						}
						else if (SONG.notes[Math.floor(Math.floor(curStep / 16))] != null)
					{
						if (SONG.notes[Math.floor(Math.floor(curStep / 16))].altAnim)
							altAnim = '-alt';
					}
					if(daNote.altNote)
						altAnim = '-alt';
						
						if(SONG.song.toLowerCase() == "cessation"){
							if(curStep >= 640 && curStep <= 790) //first drop
							{
								altAnim = '-kb';
							}
							else if(curStep >= 1040 && curStep <= 1199)
							{
								altAnim = '-kb';
							}
						}

						//Responsible for playing the animations for the Dad. -Haz
					switch (Math.abs(daNote.noteData))
					{
						case 2:
								if(qtIsBlueScreened)
									dad404.playAnim('singUP' + altAnim, true);
								else
									dad.playAnim('singUP' + altAnim, true);
							case 3:
								if(qtIsBlueScreened)
									dad404.playAnim('singRIGHT' + altAnim, true);
								else
									dad.playAnim('singRIGHT' + altAnim, true);
							case 1:
								if(qtIsBlueScreened)
									dad404.playAnim('singDOWN' + altAnim, true);
								else
									dad.playAnim('singDOWN' + altAnim, true);
							case 0:
								if(qtIsBlueScreened)
									dad404.playAnim('singLEFT' + altAnim, true);
								else
									dad.playAnim('singLEFT' + altAnim, true);
					}

					dadStrums.forEach(function(spr:FlxSprite)
							{
								if(spr.ID == Math.abs(daNote.noteData))
								{
									spr.animation.play('confirm', true);
									new FlxTimer().start(0.5, function(tmr:FlxTimer)
									{
										
										spr.animation.play('static', true);
										if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
										{
											spr.centerOffsets();
											spr.offset.x -= 13;
											spr.offset.y -= 13;
										}
										else
											spr.centerOffsets();
										
									});
								
									if(spr.animation.curAnim.name == "confirm" && spr.animation.curAnim.finished)
									{
										spr.animation.play('static', true);
									}
								}
								else if(spr.animation.curAnim.name == "confirm" && spr.animation.curAnim.finished)
								{
									spr.animation.play('static', true);
								}
								

								if(dad.animation.curAnim.name == 'idle')
								{
									spr.animation.play('static', true);
								}

								if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
								{
									spr.centerOffsets();
									spr.offset.x -= 13;
									spr.offset.y -= 13;
								}
								else
									spr.centerOffsets();
								
							});

					dad.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = 1;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				/*if (daNote.y < -daNote.height && !FlxG.save.data.downscroll || daNote.y >= strumLine.y + 106 && FlxG.save.data.downscroll)
				{

					if ((daNote.tooLate || !daNote.wasGoodHit))
					{
						noteMiss(daNote.noteData);
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}*/
				var missNote:Bool = daNote.y < -daNote.height;
				if(FlxG.save.data.downscroll) missNote = daNote.y > FlxG.height;
				if(missNote)
				{
					if(daNote.tooLate || !daNote.wasGoodHit)
						noteMiss(daNote.noteData);
					daNote.active = false;
					daNote.visible = false;
					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}

		if (!inCutscene)
		{
			keyShit();
		}
		

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}
	
	function endSong():Void
	{
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
                #if android
	        androidc.visible = false;
	        #end
		if (SONG.validScore)
		{
			#if !switch
			var averageAccuracy:Float = 0;

			for (i in 0 ... hitAccuracy.length) 
			{
				averageAccuracy += hitAccuracy[i];
			}
			averageAccuracy -= hitAccuracy.length;
			averageAccuracy = FlxMath.roundDecimal(averageAccuracy / hitAccuracy.length + 1, 2);
			Highscore.saveScore(SONG.song, songScore, storyDifficulty, averageAccuracy, maxCombo);
			#end
		}
		
		if(SONG.song.toLowerCase() == "termination"){
			FlxG.save.data.terminationBeaten = true; //Congratulations, you won!
		}

	  if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic(Paths.music('qtMenu'));

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				FlxG.switchState(new StoryMenuState());

				// if ()
				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				if (SONG.validScore)
				{
					//NGio.unlockMedal(60961);
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
				}

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			}
			else
			{
				




				var difficulty:String = "";

				if (storyDifficulty == 0)
					difficulty = '-easy';

				if (storyDifficulty == 2)
					difficulty = '-hard';

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'));
				}

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				prevCamFollow = camFollow;

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();

				LoadingState.loadAndSwitchState(new PlayState());
				}
				}
						else if (SONG.song.toLowerCase() == 'careless')
						{
							camZooming = false;
							paused = true;
							qtCarelessFin = true;
							FlxG.sound.music.pause();
							vocals.pause();
							//Conductor.songPosition = 0;
							var doof = new DialogueBox(false, CoolUtil.coolTextFile(Paths.txt('careless/carelessDialogue2')));
							doof.scrollFactor.set();
							doof.finishThing = loadSongHazard;
							camHUD.visible = false;
							schoolIntro(doof);

				
			}
		
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			FlxG.switchState(new FreeplayState());
		}
	}

	var endingSong:Bool = false;

	//Call this function to update the visuals for Censory overload!
	function CensoryOverload404():Void
	{
		if(qtIsBlueScreened){
			//Hide original versions
			boyfriend.alpha = 0;
			gf.alpha = 0;
			dad.alpha = 0;

			//New versions un-hidden.
			boyfriend404.alpha = 1;
			gf404.alpha = 1;
			dad404.alpha = 1;
		}
		else{ //Reset back to normal

			//Return to original sprites.
			boyfriend404.alpha = 0;
			gf404.alpha = 0;
			dad404.alpha = 0;

			//Hide 404 versions
			boyfriend.alpha = 1;
			gf.alpha = 1;
			dad.alpha = 1;
		}
	}

	function dodgeTimingOverride(newValue:Float = 0.22625):Void
	{
		bfDodgeTiming = newValue;
	}

	function dodgeCooldownOverride(newValue:Float = 0.1135):Void
	{
		bfDodgeCooldown = newValue;
	}	

	function KBATTACK_TOGGLE(shouldAdd:Bool = true):Void
	{
		if(shouldAdd)
			add(kb_attack_saw);
		else
			remove(kb_attack_saw);
	}

	function KBALERT_TOGGLE(shouldAdd:Bool = true):Void
	{
		if(shouldAdd)
			add(kb_attack_alert);
		else
			remove(kb_attack_alert);
	}

	//False state = Prime!
	//True state = Attack!
	function KBATTACK(state:Bool = false, soundToPlay:String = 'attack'):Void
	{
		if(!(SONG.song.toLowerCase() == "termination" || SONG.song.toLowerCase() == "extermination" || SONG.song.toLowerCase() == "tutorial" || SONG.song.toLowerCase() == 'expurgation' || SONG.song.toLowerCase() == "milf")){
			trace("Sawblade Attack Error, cannot use Termination functions outside Termination, Extermination, Expurgation or Tutorial.");
		}
		trace("HE ATACC!");
		if(state){
			FlxG.sound.play(Paths.sound(soundToPlay,'qt'),0.75);
			//Play saw attack animation
			kb_attack_saw.animation.play('fire');
			kb_attack_saw.offset.set(1600,0);

			/*kb_attack_saw.animation.finishCallback = function(pog:String){
				if(state) //I don't get it.
					remove(kb_attack_saw);
			}*/

			//Slight delay for animation. Yeah I know I should be doing this using curStep and curBeat and what not, but I'm lazy -Haz
			new FlxTimer().start(0.09, function(tmr:FlxTimer)
			{
				if(!bfDodging){
					//MURDER THE BITCH!
					deathBySawBlade = true;
					health -= 404;
				}
			});
		}else{
			kb_attack_saw.animation.play('prepare');
			kb_attack_saw.offset.set(-333,0);
		}
	}
	function bg_RedFlash(pointless:Bool = false):Void
		{
			trace("BEWARE");
			bgFlash.animation.play('bg_Flash_Normal');
		}
	function bg_RedFlash_Critical(pointless:Bool = false):Void
		{
			trace("BEWARE, HE'S FUCKING CRAZY!!");
			bgFlash.animation.play('bg_Flash_Critical');
		}
	function bg_RedFlash_Longer(pointless:Bool = false):Void
		{
			trace("WARNING");
			bgFlash.animation.play('bg_Flash_Long');
		}
	function bg_RedFlash_Critical_Longer(pointless:Bool = false):Void
		{
			trace("STARTING");
			bgFlash.animation.play('bg_Flash_Critical_Long');
		}
	function KBATTACK_ALERT(pointless:Bool = false):Void //For some reason, modchart doesn't like functions with no parameter? why? dunno.
	{
		if(!(SONG.song.toLowerCase() == "termination" || SONG.song.toLowerCase() == "extermination" || SONG.song.toLowerCase() == "tutorial" || SONG.song.toLowerCase() == 'expurgation' || SONG.song.toLowerCase() == "milf")){
			trace("Sawblade Alert Error, cannot use Termination functions outside Termination, Extermination, Expurgation or Tutorial.");
		}
		trace("DANGER!");
		kb_attack_alert.animation.play('alert');
		FlxG.sound.play(Paths.sound('alert','qt'), 1);
	}

	//OLD ATTACK DOUBLE VARIATION
	function KBATTACK_ALERTDOUBLE(pointless:Bool = false):Void
	{
		if(!(SONG.song.toLowerCase() == "termination" || SONG.song.toLowerCase() == "extermination" || SONG.song.toLowerCase() == "tutorial")){
			trace("Sawblade AlertDOUBLE Error, cannot use Termination functions outside Termination, Extermination or Tutorial.");
		}
		trace("DANGER DOUBLE INCOMING!!");
		kb_attack_alert.animation.play('alertDOUBLE');
		FlxG.sound.play(Paths.sound('old/alertALT','qt'), 1);
	}

	//Pincer logic, used by the modchart but can be hardcoded like saws if you want.
	function KBPINCER_PREPARE(laneID:Int,goAway:Bool):Void
	{
		if(!(SONG.song.toLowerCase() == "termination" || SONG.song.toLowerCase() == "extermination" || SONG.song.toLowerCase() == "tutorial")){
			trace("Pincer Error, cannot use Termination functions outside Termination, Extermination or Tutorial.");
		}
		else{
			//1 = BF far left, 4 = BF far right. This only works for BF!
			//Update! 5 now refers to the far left lane. Mainly used for the shaking section or whatever.
			pincer1.cameras = [camHUD];
			pincer2.cameras = [camHUD];
			pincer3.cameras = [camHUD];
			pincer4.cameras = [camHUD];

			//This is probably the most disgusting code I've ever written in my life.
			//All because I can't be bothered to learn arrays and shit.
			//Would've converted this to a switch case but I'm too scared to change it so deal with it.
			if(laneID==1){
				pincer1.loadGraphic(Paths.image('bonus/pincer-open'), false);
				if(FlxG.save.data.downscroll){
					if(!goAway){
						pincer1.setPosition(strumLineNotes.members[4].x,strumLineNotes.members[4].y+500);
						add(pincer1);
						FlxTween.tween(pincer1, {y : strumLineNotes.members[4].y}, 0.3, {ease: FlxEase.elasticOut});
					}else{
						FlxTween.tween(pincer1, {y : strumLineNotes.members[4].y+500}, 0.4, {ease: FlxEase.bounceIn, onComplete: function(twn:FlxTween){remove(pincer1);}});
					}
				}else{
					if(!goAway){
						pincer1.setPosition(strumLineNotes.members[4].x,strumLineNotes.members[4].y-500);
						add(pincer1);
						FlxTween.tween(pincer1, {y : strumLineNotes.members[4].y}, 0.3, {ease: FlxEase.elasticOut});
					}else{
						FlxTween.tween(pincer1, {y : strumLineNotes.members[4].y-500}, 0.4, {ease: FlxEase.bounceIn, onComplete: function(twn:FlxTween){remove(pincer1);}});
					}
				}
			}
			else if(laneID==5){ //Targets far left note for Dad (KB). Used for the screenshake thing
				pincer1.loadGraphic(Paths.image('bonus/pincer-open'), false);
				if(FlxG.save.data.downscroll){
					if(!goAway){
						pincer1.setPosition(strumLineNotes.members[0].x,strumLineNotes.members[0].y+500);
						add(pincer1);
						FlxTween.tween(pincer1, {y : strumLineNotes.members[0].y}, 0.3, {ease: FlxEase.elasticOut});
					}else{
						FlxTween.tween(pincer1, {y : strumLineNotes.members[0].y+500}, 0.4, {ease: FlxEase.bounceIn, onComplete: function(twn:FlxTween){remove(pincer1);}});
					}
				}else{
					if(!goAway){
						pincer1.setPosition(strumLineNotes.members[0].x,strumLineNotes.members[5].y-500);
						add(pincer1);
						FlxTween.tween(pincer1, {y : strumLineNotes.members[0].y}, 0.3, {ease: FlxEase.elasticOut});
					}else{
						FlxTween.tween(pincer1, {y : strumLineNotes.members[0].y-500}, 0.4, {ease: FlxEase.bounceIn, onComplete: function(twn:FlxTween){remove(pincer1);}});
					}
				}
			}
			else if(laneID==2){
				pincer2.loadGraphic(Paths.image('bonus/pincer-open'), false);
				if(FlxG.save.data.downscroll){
					if(!goAway){
						pincer2.setPosition(strumLineNotes.members[5].x,strumLineNotes.members[5].y+500);
						add(pincer2);
						FlxTween.tween(pincer2, {y : strumLineNotes.members[5].y}, 0.3, {ease: FlxEase.elasticOut});
					}else{
						FlxTween.tween(pincer2, {y : strumLineNotes.members[5].y+500}, 0.4, {ease: FlxEase.bounceIn, onComplete: function(twn:FlxTween){remove(pincer2);}});
					}
				}else{
					if(!goAway){
						pincer2.setPosition(strumLineNotes.members[5].x,strumLineNotes.members[5].y-500);
						add(pincer2);
						FlxTween.tween(pincer2, {y : strumLineNotes.members[5].y}, 0.3, {ease: FlxEase.elasticOut});
					}else{
						FlxTween.tween(pincer2, {y : strumLineNotes.members[5].y-500}, 0.4, {ease: FlxEase.bounceIn, onComplete: function(twn:FlxTween){remove(pincer2);}});
					}
				}
			}
			else if(laneID==3){
				pincer3.loadGraphic(Paths.image('bonus/pincer-open'), false);
				if(FlxG.save.data.downscroll){
					if(!goAway){
						pincer3.setPosition(strumLineNotes.members[6].x,strumLineNotes.members[6].y+500);
						add(pincer3);
						FlxTween.tween(pincer3, {y : strumLineNotes.members[6].y}, 0.3, {ease: FlxEase.elasticOut});
					}else{
						FlxTween.tween(pincer3, {y : strumLineNotes.members[6].y+500}, 0.4, {ease: FlxEase.bounceIn, onComplete: function(twn:FlxTween){remove(pincer3);}});
					}
				}else{
					if(!goAway){
						pincer3.setPosition(strumLineNotes.members[6].x,strumLineNotes.members[6].y-500);
						add(pincer3);
						FlxTween.tween(pincer3, {y : strumLineNotes.members[6].y}, 0.3, {ease: FlxEase.elasticOut});
					}else{
						FlxTween.tween(pincer3, {y : strumLineNotes.members[6].y-500}, 0.4, {ease: FlxEase.bounceIn, onComplete: function(twn:FlxTween){remove(pincer3);}});
					}
				}
			}
			else if(laneID==4){
				pincer4.loadGraphic(Paths.image('bonus/pincer-open'), false);
				if(FlxG.save.data.downscroll){
					if(!goAway){
						pincer4.setPosition(strumLineNotes.members[7].x,strumLineNotes.members[7].y+500);
						add(pincer4);
						FlxTween.tween(pincer4, {y : strumLineNotes.members[7].y}, 0.3, {ease: FlxEase.elasticOut});
					}else{
						FlxTween.tween(pincer4, {y : strumLineNotes.members[7].y+500}, 0.4, {ease: FlxEase.bounceIn, onComplete: function(twn:FlxTween){remove(pincer4);}});
					}
				}else{
					if(!goAway){
						pincer4.setPosition(strumLineNotes.members[7].x,strumLineNotes.members[7].y-500);
						add(pincer4);
						FlxTween.tween(pincer4, {y : strumLineNotes.members[7].y}, 0.3, {ease: FlxEase.elasticOut});
					}else{
						FlxTween.tween(pincer4, {y : strumLineNotes.members[7].y-500}, 0.4, {ease: FlxEase.bounceIn, onComplete: function(twn:FlxTween){remove(pincer4);}});
					}
				}
			}else
				trace("Invalid LaneID for pincer");
		}
	}
	function KBPINCER_GRAB(laneID:Int):Void
	{
		if(!(SONG.song.toLowerCase() == "termination" || SONG.song.toLowerCase() == "extermination" || SONG.song.toLowerCase() == "tutorial")){
			trace("PincerGRAB Error, cannot use Termination functions outside Termination, Extermination or Tutorial.");
		}
		else{
			switch(laneID)
			{
				case 1 | 5:
					pincer1.loadGraphic(Paths.image('bonus/pincer-close'), false);
				case 2:
					pincer2.loadGraphic(Paths.image('bonus/pincer-close'), false);
				case 3:
					pincer3.loadGraphic(Paths.image('bonus/pincer-close'), false);
				case 4:
					pincer4.loadGraphic(Paths.image('bonus/pincer-close'), false);
				default:
					trace("Invalid LaneID for pincerGRAB");
			}
		}
	}

	function terminationEndEarly():Void //Yep, terminate was originally called termination while termination was going to have a different name. Can't be bothered to update some names though like this so sorry for any confusion -Haz
		{
			if(!qtCarelessFinCalled){
				qt_tv01.animation.play("error");
				canPause = false;
				inCutscene = true;
				paused = true;
				camZooming = false;
				qtCarelessFin = true;
				qtCarelessFinCalled = true; //Variable to prevent constantly repeating this code.
				//Slight delay... -Haz
				new FlxTimer().start(3, function(tmr:FlxTimer)
				{
					camHUD.visible = false;
					//FlxG.sound.music.pause();
					//vocals.pause();
					var doof = new DialogueBox(false, CoolUtil.coolTextFile(Paths.txt('terminate/terminateDialogueEND')));
					doof.scrollFactor.set();
					doof.finishThing = loadSongHazard;
					schoolIntro(doof);
				});
			}
		}

	function endScreenHazard():Void //For displaying the "thank you for playing" screen on Cessation
	{
		var black:FlxSprite = new FlxSprite(-300, -100).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
		black.scrollFactor.set();

		var screen:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('bonus/FinalScreen'));
		screen.setGraphicSize(Std.int(screen.width * 0.625));
		screen.antialiasing = true;
		screen.scrollFactor.set();
		screen.screenCenter();

		var hasTriggeredAlready:Bool = false;

		screen.alpha = 0;
		black.alpha = 0;
		
		add(black);
		add(screen);

		//Fade in code stolen from schoolIntro() >:3
		new FlxTimer().start(0.15, function(swagTimer:FlxTimer)
		{
			black.alpha += 0.075;
			if (black.alpha < 1)
			{
				swagTimer.reset();
			}
			else
			{
				screen.alpha += 0.075;
				if (screen.alpha < 1)
				{
					swagTimer.reset();
				}

				canSkipEndScreen = true;
				//Wait 12 seconds, then do shit -Haz
				new FlxTimer().start(12, function(tmr:FlxTimer)
				{
					if(!hasTriggeredAlready){
						hasTriggeredAlready = true;
						loadSongHazard();
					}
				});
			}
		});		
	}

	function loadSongHazard():Void //Used for Careless, Termination, and Cessation when they end -Haz
	{
		canSkipEndScreen = false;

		//Very disgusting but it works... kinda
		if (SONG.song.toLowerCase() == 'cessation')
		{
			trace('Switching to MainMenu. Thanks for playing.');
			FlxG.sound.playMusic(Paths.music('thanks'));
			FlxG.switchState(new MainMenuState());
			Conductor.changeBPM(102); //lmao, this code doesn't even do anything useful! (aaaaaaaaaaaaaaaaaaaaaa)
		}	
		else if (SONG.song.toLowerCase() == 'terminate')
		{
			FlxG.log.notice("Back to the menu you go!!!");

			FlxG.sound.playMusic(Paths.music('qtMenu'));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;

			FlxG.switchState(new StoryMenuState());

  }
  }
	private function popUpScore(strumtime:Float, note:Note):Void
	{
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Float = 350;

		var daRating:String = "sick";
		var splashIsOn:Bool = true;
		var healthAdd:Float = 0.025;

		if (noteDiff > Conductor.safeZoneOffset * 0.7)
		{
			daRating = 'shit';
			
			totalAccuracy += 0.2;
			score = 50;
			splashIsOn = false;
			healthAdd = 0.01;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.5)
		{
			daRating = 'bad';

			totalAccuracy += 0.5;
			score = 100;
			splashIsOn = false;
			healthAdd = 0.02;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.185)
		{
			daRating = 'good';
			
			totalAccuracy += 1;
			score = 200;
			splashIsOn = false;
			healthAdd = 0.025;
		}
		else
		{
			daRating = 'sick';

			totalAccuracy += 1.2;
			score = 350;
			splashIsOn = true;
			healthAdd = 0.035;
		}

		if (totalAccuracy > (misses + songNotesHit)) {
			totalAccuracy = (misses + songNotesHit);
		}

		if(splashIsOn == true)
		{
			var a:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
			a.setupNoteSplash(note.x, note.y, note.noteData);
			grpNoteSplashes.add(a);
		}

		var modifiers:Float = 1;
		if(randomNotes)
			modifiers += 1.15;
		if(instaFail)
			modifiers += 1.1;
		if(noFail)
			modifiers = 0;
		songScore += Std.int(score * modifiers);
		health += healthAdd;

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (curStage.startsWith('school'))
		{
			pixelShitPart1 = 'weeb/pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(rating);

		if (!curStage.startsWith('school'))
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = true;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = true;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		seperatedScore.push(Math.floor(combo / 100));
		seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			if (!curStage.startsWith('school'))
			{
				numScore.antialiasing = true;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			if (combo >= 10 || combo == 0)
				add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection += 1;
	}

	

	private function keyShit():Void
	{
		var control = PlayerSettings.player1.controls;
		
		//Dodge code only works on termination and Tutorial -Haz
		if(SONG.song.toLowerCase() == "termination" || SONG.song.toLowerCase()=='tutorial' || SONG.song.toLowerCase() == 'extermination'){
			//Dodge code, yes it's bad but oh well. -Haz
			//var dodgeButton = controls.ACCEPT; //I have no idea how to add custom controls so fuck it. -Haz

			if(FlxG.keys.justPressed.SPACE #if android || _virtualpad.buttonA.justPressed #end)
				trace('butttonpressed');

			if(FlxG.keys.justPressed.SPACE #if android || _virtualpad.buttonA.justPressed #end && !bfDodging && bfCanDodge){
				trace('DODGE START!');
				bfDodging = true;
				bfCanDodge = false;

				if(qtIsBlueScreened)
					boyfriend404.playAnim('dodge');
				else
					boyfriend.playAnim('dodge');

				FlxG.sound.play(Paths.sound('dodge01'));

				//Wait, then set bfDodging back to false. -Haz
				//V1.2 - Timer lasts a bit longer (by 0.00225)
				//new FlxTimer().start(0.22625, function(tmr:FlxTimer) 		//COMMENT THIS IF YOU WANT TO USE DOUBLE SAW VARIATIONS!
				//new FlxTimer().start(0.15, function(tmr:FlxTimer)			//UNCOMMENT THIS IF YOU WANT TO USE DOUBLE SAW VARIATIONS!
				new FlxTimer().start(bfDodgeTiming, function(tmr:FlxTimer) 	//COMMENT THIS IF YOU WANT TO USE DOUBLE SAW VARIATIONS!
				{
					bfDodging=false;
					boyfriend.dance(); //V1.3 = This forces the animation to end when you are no longer safe as the animation keeps misleading people.
					trace('DODGE END!');
					//Cooldown timer so you can't keep spamming it.
					//V1.3 = Incremented this by a little (0.005)
					//new FlxTimer().start(0.1135, function(tmr:FlxTimer) 	//COMMENT THIS IF YOU WANT TO USE DOUBLE SAW VARIATIONS!
					//new FlxTimer().start(0.1, function(tmr:FlxTimer) 		//UNCOMMENT THIS IF YOU WANT TO USE DOUBLE SAW VARIATIONS!
					new FlxTimer().start(bfDodgeCooldown, function(tmr:FlxTimer) 	//COMMENT THIS IF YOU WANT TO USE DOUBLE SAW VARIATIONS!
					{
						bfCanDodge=true;
						trace('DODGE RECHARGED!');
					});
				});
			}
		}
		
		if(SONG.song.toLowerCase()=='milf'){//Wait... ¿¿¿MILF???
			//Dodge code, yes it's bad but oh well. -Haz
			//var dodgeButton = controls.ACCEPT; //I have no idea how to add custom controls so fuck it. -Haz
			//Haha Copy-paste LOL (although modified a bit)
			if(FlxG.keys.justPressed.SPACE #if android || _virtualpad.buttonA.justPressed #end)
				trace('butttonpressed');

			if(FlxG.keys.justPressed.SPACE #if android || _virtualpad.buttonA.justPressed #end && !bfDodging && bfCanDodge){
				trace('DODGE START!');
				bfDodging = true;
				bfCanDodge = false;

				if(qtIsBlueScreened)
					boyfriend404.playAnim('dodge');
				else
					boyfriend.playAnim('dodge');

				FlxG.sound.play(Paths.sound('dodge01'));

				//Wait, then set bfDodging back to false. -Haz
				//V1.2 - Timer lasts a bit longer (by 0.00225)
				//new FlxTimer().start(0.22625, function(tmr:FlxTimer) 		//COMMENT THIS IF YOU WANT TO USE DOUBLE SAW VARIATIONS!
				new FlxTimer().start(bfDodgeTiming, function(tmr:FlxTimer)			//UNCOMMENT THIS IF YOU WANT TO USE DOUBLE SAW VARIATIONS!
				//new FlxTimer().start(bfDodgeTiming, function(tmr:FlxTimer) 	//COMMENT THIS IF YOU WANT TO USE DOUBLE SAW VARIATIONS!
				{
					bfDodging=false;
					boyfriend.dance(); //V1.3 = This forces the animation to end when you are no longer safe as the animation keeps misleading people.
					trace('DODGE END!');
					//Cooldown timer so you can't keep spamming it.
					//V1.3 = Incremented this by a little (0.005)
					//new FlxTimer().start(0.1135, function(tmr:FlxTimer) 	//COMMENT THIS IF YOU WANT TO USE DOUBLE SAW VARIATIONS!
					new FlxTimer().start(bfDodgeCooldown, function(tmr:FlxTimer) 		//UNCOMMENT THIS IF YOU WANT TO USE DOUBLE SAW VARIATIONS!
					//new FlxTimer().start(bfDodgeCooldown, function(tmr:FlxTimer) 	//COMMENT THIS IF YOU WANT TO USE DOUBLE SAW VARIATIONS!
					{
						bfCanDodge=true;
						trace('DODGE RECHARGED!');//I've separated the dodge code from Censory-Superload so that the Bf animation lasts as long as it needs to last -DrkFon376
					});
				});
			}
		}

		if(SONG.song.toLowerCase()=='expurgation'){
			//Dodge code, yes it's bad but oh well. -Haz
			//var dodgeButton = controls.ACCEPT; //I have no idea how to add custom controls so fuck it. -Haz
			//Haha Copy-paste LOL (although modified a bit) -Again lol
			if(FlxG.keys.justPressed.SPACE #if android || _virtualpad.buttonA.justPressed #end)
				trace('butttonpressed');

			if(FlxG.keys.justPressed.SPACE #if android || _virtualpad.buttonA.justPressed #end && !bfDodging && bfCanDodge){
				trace('DODGE START!');
				bfDodging = true;
				bfCanDodge = false;

				if(qtIsBlueScreened)
					boyfriend404.playAnim('dodge');
				else
					boyfriend.playAnim('dodge');

				FlxG.sound.play(Paths.sound('dodge01'));

				//Wait, then set bfDodging back to false. -Haz
				//V1.2 - Timer lasts a bit longer (by 0.00225)
				//new FlxTimer().start(0.22625, function(tmr:FlxTimer) 		//COMMENT THIS IF YOU WANT TO USE DOUBLE SAW VARIATIONS!
				//new FlxTimer().start(0.2715, function(tmr:FlxTimer)			//UNCOMMENT THIS IF YOU WANT TO USE DOUBLE SAW VARIATIONS!
				new FlxTimer().start(bfDodgeTiming, function(tmr:FlxTimer) 	//COMMENT THIS IF YOU WANT TO USE DOUBLE SAW VARIATIONS!
				{
					bfDodging=false;
					boyfriend.dance(); //V1.3 = This forces the animation to end when you are no longer safe as the animation keeps misleading people.
					trace('DODGE END!');
					//Cooldown timer so you can't keep spamming it.
					//V1.3 = Incremented this by a little (0.005)
					//new FlxTimer().start(0.1135, function(tmr:FlxTimer) 	//COMMENT THIS IF YOU WANT TO USE DOUBLE SAW VARIATIONS!
					//new FlxTimer().start(0.1135, function(tmr:FlxTimer) 		//UNCOMMENT THIS IF YOU WANT TO USE DOUBLE SAW VARIATIONS!
					new FlxTimer().start(bfDodgeCooldown, function(tmr:FlxTimer) 	//COMMENT THIS IF YOU WANT TO USE DOUBLE SAW VARIATIONS!
					{
						bfCanDodge=true;
						trace('DODGE RECHARGED!');//I've separated the dodge code from Censory-Superload so that the Bf animation lasts as long as it needs to last -DrkFon376
					});
				});
			}
		}

		// control arrays, order L D U R
		var holdArray:Array<Bool> = [control.LEFT, control.DOWN, control.UP, control.RIGHT];
		var pressArray:Array<Bool> = [
			control.LEFT_P,
			control.DOWN_P,
			control.UP_P,
			control.RIGHT_P
		];
		var releaseArray:Array<Bool> = [
			control.LEFT_R,
			control.DOWN_R,
			control.UP_R,
			control.RIGHT_R
		];

		if (FlxG.save.data.botAutoPlay)
		{
			holdArray = [false, false, false, false];
			pressArray = [false, false, false, false];
			releaseArray = [false, false, false, false];
		}
	 
		// FlxG.watch.addQuick('asdfa', upP);
		if (pressArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
		{

			boyfriend.holdTimer = 0;

			var possibleNotes:Array<Note> = [];

			var ignoreList:Array<Int> = [];

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
				{
					// the sorting probably doesn't need to be in here? who cares lol
					possibleNotes.push(daNote);
					possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

					ignoreList.push(daNote.noteData);
				}
			});

			if (perfectMode)
				goodNoteHit(possibleNotes[0]);
			else if (possibleNotes.length > 0)
			{
				for (coolNote in possibleNotes)
				{
					if (pressArray[coolNote.noteData])
					{
						goodNoteHit(coolNote);
						clicks.push(time);
					}
				}
			}
			else
			{
				//badNoteCheck();
				clicks.push(time);
			}
		}

		if (holdArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData] && daNote.alpha != 0.1)
					{
						
						goodNoteHit(daNote);
					}
					
				});
		}

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || FlxG.save.data.botAutoPlay))
				{
					if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss') && boyfriend.animation.curAnim.curFrame >= 10)
						boyfriend.dance();
				}

		notes.forEachAlive(function(daNote:Note)
		{
			if (FlxG.save.data.downscroll && daNote.y > strumLine.y || !FlxG.save.data.downscroll && daNote.y < strumLine.y)
			{
				// Force good note hit regardless if it's too late to hit it or not as a fail safe
				if (FlxG.save.data.botAutoPlay && daNote.canBeHit && daNote.mustPress || FlxG.save.data.botAutoPlay && daNote.tooLate && daNote.mustPress)
				{
					
					goodNoteHit(daNote);
					boyfriend.holdTimer = daNote.sustainLength;
					playerStrums.forEach(function(spr:FlxSprite)
							{
								if(spr.ID == Math.abs(daNote.noteData))
								{
									spr.animation.play('confirm', true);
									new FlxTimer().start(0.5, function(tmr:FlxTimer)
									{
										
										spr.animation.play('static', true);
										if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
										{
											spr.centerOffsets();
											spr.offset.x -= 13;
											spr.offset.y -= 13;
										}
										else
											spr.centerOffsets();
										
									});
								
									if(spr.animation.curAnim.name == "confirm" && spr.animation.curAnim.finished)
									{
										spr.animation.play('static', true);
									}
								}
								else if(spr.animation.curAnim.name == "confirm" && spr.animation.curAnim.finished)
								{
									spr.animation.play('static', true);
								}
								

								if(boyfriend.animation.curAnim.name == 'idle')
								{
									spr.animation.play('static', true);
								}

								if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
								{
									spr.centerOffsets();
									spr.offset.x -= 13;
									spr.offset.y -= 13;
								}
								else
									spr.centerOffsets();
								
							});
					
				}
			}
		});

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || FlxG.save.data.botAutoPlay))
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss') && boyfriend.animation.curAnim.curFrame >= 10)
				boyfriend.dance();
		}

		if(!FlxG.save.data.botAutoPlay)
		{
			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (pressArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (!holdArray[spr.ID])
						spr.animation.play('static');
		 
					if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
					{
						spr.centerOffsets();
						spr.offset.x -= 13;
						spr.offset.y -= 13;
					}
					else
						spr.centerOffsets();
			});
		}
		
	}

	function noteMiss(direction:Int = 1):Void
	{
		if (noFail == false)
		{
			var rating:FlxSprite = new FlxSprite();
			var coolText:FlxText = new FlxText(0, 0, 0, " ", 32);
			coolText.screenCenter();
			coolText.x = FlxG.width * 0.55;
			misses++;
			health -= 0.045;
			if(PlayState.SONG.song.toLowerCase()=='expurgation'){
				health -= 0.1025; //THAT'S ALOTA DAMAGE
				interupt = true;
				totalDamageTaken += 0.04;
			}else{
				health -= 0.05;
			}
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			songScore -= 15;

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			rating.loadGraphic(Paths.image("miss"));
			rating.screenCenter();
			rating.x = coolText.x - 40;
			rating.y -= 60;
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);
			rating.setGraphicSize(Std.int(rating.width * 0.8));
			add(rating);
			FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
			});

			
			boyfriend.stunned = true;

			// get stunned for 5 seconds
			new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});

			switch (direction)
			{
				case 0:
					boyfriend.playAnim('singLEFTmiss', true);
				case 1:
					boyfriend.playAnim('singDOWNmiss', true);
				case 2:
					boyfriend.playAnim('singUPmiss', true);
				case 3:
					boyfriend.playAnim('singRIGHTmiss', true);
			}
		}
	}

	/*function badNoteCheck()
	{
		// just double pasting this shit cuz fuk u
		// REDO THIS SYSTEM!
		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;
		
		songNotesHit += 1;
		
		if (leftP)
			noteMiss(0);
		if (downP)
			noteMiss(1);
		if (upP)
			noteMiss(2);
		if (rightP)
			noteMiss(3);
		hitAccuracy.push(totalAccuracy);
	}*/

	function goodNoteHit(note:Note):Void
	{
		songNotesHit += 1;
		hitAccuracy.push(totalAccuracy);
		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				popUpScore(note.strumTime, note);
				combo += 1;
				if(FlxG.save.data.hitSounds)
					FlxG.sound.play(Paths.sound("hit2"), FlxG.random.float(0.24, 0.48));
			}
			else
			{
				if(FlxG.save.data.hitSounds)
					FlxG.sound.play(Paths.sound("hit1"), FlxG.random.float(0.01, 0.015));
			}
			

			var altAnim:String = "";

			if (SONG.notes[Math.floor(curSection)] != null)
			{
				if (SONG.notes[Math.floor(curSection)].altAnim)
					altAnim = '-alt';
			}
			if(note.altNote) altAnim = '-alt';

			switch (note.noteData)
			{
				case 0:
					boyfriend.playAnim('singLEFT' + altAnim, true);
				case 1:
					boyfriend.playAnim('singDOWN' + altAnim, true);
				case 2:
					boyfriend.playAnim('singUP' + altAnim, true);
				case 3:
					boyfriend.playAnim('singRIGHT' + altAnim, true);
			}

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
				}
			});

			note.wasGoodHit = true;
			vocals.volume = 1;

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	var fastCarCanDrive:Bool = true;

	

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive()
	{
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		FlxG.camera.flash(FlxColor.WHITE, 0.5);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	function boyfriendSpinMic():Void
	{
		spinMicBeat = curBeat;
		spinMicOffset = FlxG.random.int(4, 15);
		boyfriend.playAnim('spinMic', true);
	}

	var stepOfLast = 0;
	
	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		/*if (dad.curCharacter == 'spooky' && curStep % 4 == 2)
		{
			// dad.dance();
		}*/
		
		//For trolling :)
		if (curSong.toLowerCase() == 'cessation'){
			if(hazardRandom==5){
				if(curStep == 1504){
					add(kb_attack_alert);
					KBATTACK_ALERT();
				}
				else if (curStep == 1508)
					KBATTACK_ALERT();
				else if(curStep == 1512){
					FlxG.sound.play(Paths.sound('bruh'),0.75);
					add(cessationTroll);
				}
					
				else if(curStep == 1520)
					remove(cessationTroll);
			}
		}
		//Animating every beat is too slow, so I'm doing this every step instead (previously was on every frame so it actually has time to animate through frames). -Haz
		if (curSong.toLowerCase() == 'censory-overload'){
			//Making GF scared for error section
			if(curBeat>=704 && curBeat<832 && curStep % 2 == 0)
			{
				gf.playAnim('scared', true);
				if(!Main.qtOptimisation)
					gf404.playAnim('scared', true);
			}
		}
		//Midsong events for Termination (such as the sawblade attack)
		else if (curSong.toLowerCase() == 'termination'){
			
			//For animating KB during the 404 section since he animates every half beat, not every beat.
			if(qtIsBlueScreened)
			{
				//Termination KB animates every 2 curstep instead of 4 (aka, every half beat, not every beat!)
				if (SONG.notes[Math.floor(curStep / 16)].mustHitSection && !dad404.animation.curAnim.name.startsWith("sing") && curStep % 2 == 0)
				{
					dad404.dance();
				}
			}

			//Making GF scared for error section
			if(curStep>=2816 && curStep<3328 && curStep % 2 == 0)
			{
				gf.playAnim('scared', true);
				if(!Main.qtOptimisation)
					gf404.playAnim('scared', true);
			}


			switch (curStep)
			{
				//Commented out stuff are for the double sawblade variations.
				//It is recommended to not uncomment them unless you know what you're doing. They are also not polished at all so don't complain about them if you do uncomment them.
				
				
				//CONVERTED THE CUSTOM INTRO FROM MODCHART INTO HARDCODE OR WHATEVER! NO MORE INVISIBLE NOTES DUE TO NO MODCHART SUPPORT!
				case 1:
					qt_tv01.animation.play("instructions");
					FlxTween.tween(strumLineNotes.members[0], {y: strumLineNotes.members[0].y + 10, alpha: 1}, 1.2, {ease: FlxEase.cubeOut});
					FlxTween.tween(strumLineNotes.members[7], {y: strumLineNotes.members[7].y + 10, alpha: 1}, 1.2, {ease: FlxEase.cubeOut});
					if(!Main.qtOptimisation){
						boyfriend404.alpha = 0; 
						dad404.alpha = 0;
						gf404.alpha = 0;
					}
				case 32:
					FlxTween.tween(strumLineNotes.members[1], {y: strumLineNotes.members[1].y + 10, alpha: 1}, 1.2, {ease: FlxEase.cubeOut});
					FlxTween.tween(strumLineNotes.members[6], {y: strumLineNotes.members[6].y + 10, alpha: 1}, 1.2, {ease: FlxEase.cubeOut});
				case 96:
					FlxTween.tween(strumLineNotes.members[3], {y: strumLineNotes.members[3].y + 10, alpha: 1}, 1.2, {ease: FlxEase.cubeOut});
					FlxTween.tween(strumLineNotes.members[4], {y: strumLineNotes.members[4].y + 10, alpha: 1}, 1.2, {ease: FlxEase.cubeOut});
				case 64:
					qt_tv01.animation.play("gl");
					FlxTween.tween(strumLineNotes.members[2], {y: strumLineNotes.members[2].y + 10, alpha: 1}, 1.2, {ease: FlxEase.cubeOut});
					FlxTween.tween(strumLineNotes.members[5], {y: strumLineNotes.members[5].y + 10, alpha: 1}, 1.2, {ease: FlxEase.cubeOut});
				case 112:
					add(kb_attack_saw);
					add(kb_attack_alert);
					KBATTACK_ALERT();
					KBATTACK();
				case 116:
					//KBATTACK_ALERTDOUBLE();
					KBATTACK_ALERT();
				case 120:
					//KBATTACK(true, "old/attack_alt01");
					KBATTACK(true);
					qt_tv01.animation.play("idle");
					for (boi in strumLineNotes.members) { //FAIL SAFE TO ENSURE THAT ALL THE NOTES ARE VISIBLE WHEN PLAYING!!!!!
						boi.alpha = 1;
					}
				//case 123:
					//KBATTACK();
				//case 124:
					//FlxTween.tween(strumLineNotes.members[0], {alpha: 0}, 2, {ease: FlxEase.sineInOut}); //for testing outro code
					//KBATTACK(true, "old/attack_alt02");
				case 1280:
					qt_tv01.animation.play("idle");
				case 1760:
					qt_tv01.animation.play("watch");
				case 1792:
					qt_tv01.animation.play("idle");

				case 1776 | 1904 | 2032 | 2576 | 2596 | 2608 | 2624 | 2640 | 2660 | 2672 | 2704 | 2736 | 3072 | 3084 | 3104 | 3116 | 3136 | 3152 | 3168 | 3184 | 3216 | 3248 | 3312:
					KBATTACK_ALERT();
					KBATTACK();
				case 1780 | 1908 | 2036 | 2580 | 2600 | 2612 | 2628 | 2644 | 2664 | 2676 | 2708 | 2740 | 3076 | 3088 | 3108 | 3120 | 3140 | 3156 | 3172 | 3188 | 3220 | 3252 | 3316:
					KBATTACK_ALERT();
				case 1784 | 1912 | 2040 | 2584 | 2604 | 2616 | 2632 | 2648 | 2668 | 2680 | 2712 | 2744 | 3080 | 3092 | 3112 | 3124 | 3144 | 3160 | 3176 | 3192 | 3224 | 3256 | 3320:
					KBATTACK(true);

				//Sawblades before bluescreen thing
				//These were seperated for double sawblade experimentation if you're wondering.
				//My god this organisation is so bad. Too bad!
				case 2304 | 2320 | 2340 | 2368 | 2384 | 2404:
					KBATTACK_ALERT();
					KBATTACK();
				case 2308 | 2324 | 2344 | 2372 | 2388 | 2408:
					KBATTACK_ALERT();
				case 2312 | 2328 | 2348 | 2376 | 2392 | 2412:
					KBATTACK(true);
				case 2352 | 2416:
					KBATTACK_ALERT();
					KBATTACK();
				case 2356 | 2420:
					//KBATTACK_ALERTDOUBLE();
					KBATTACK_ALERT();
				case 2360 | 2424:
					KBATTACK(true);
				case 2363 | 2427:
					//KBATTACK();
				case 2364 | 2428:
					//KBATTACK(true, "old/attack_alt02");

				case 2560:
					KBATTACK_ALERT();
					KBATTACK();
					qt_tv01.animation.play("eye");
				case 2564:
					KBATTACK_ALERT();
				case 2568:
					KBATTACK(true);

				case 2808:
					//Change to glitch background
					if(!Main.qtOptimisation){
						streetBGerror.visible = true;
						streetBG.visible = false;
					}
					FlxG.camera.shake(0.0075,0.675);
					qt_tv01.animation.play("error");

				case 2816: //404 section
					qt_tv01.animation.play("404");
					gfSpeed = 1;
					//Change to bluescreen background
					if(!Main.qtOptimisation){
						streetBG.visible = false;
						streetBGerror.visible = false;
						streetFrontError.visible = true;
						qtIsBlueScreened = true;
						CensoryOverload404();
					}
				case 3328: //Final drop
					qt_tv01.animation.play("alert");
					gfSpeed = 1;
					//Revert back to normal
					if(!Main.qtOptimisation){
						streetBG.visible = true;
						streetFrontError.visible = false;
						qtIsBlueScreened = false;
						CensoryOverload404();
					}

				case 3376 | 3408 | 3424 | 3440 | 3576 | 3636 | 3648 | 3680 | 3696 | 3888 | 3936 | 3952 | 4096 | 4108 | 4128 | 4140 | 4160 | 4176 | 4192 | 4204:
					KBATTACK_ALERT();
					KBATTACK();
				case 3380 | 3412 | 3428 | 3444 | 3580 | 3640 | 3652 | 3684 | 3700 | 3892 | 3940 | 3956 | 4100 | 4112 | 4132 | 4144 | 4164 | 4180 | 4196 | 4208:
					KBATTACK_ALERT();
				case 3384 | 3416 | 3432 | 3448 | 3584 | 3644 | 3656 | 3688 | 3704 | 3896 | 3944 | 3960 | 4104 | 4116 | 4136 | 4148 | 4168 | 4184 | 4200 | 4212:
					KBATTACK(true);
				case 4352: //Custom outro hardcoded instead of being part of the modchart! 
					qt_tv01.animation.play("idle");
					FlxTween.tween(strumLineNotes.members[2], {alpha: 0}, 1.1, {ease: FlxEase.sineInOut});
				case 4384:
					FlxTween.tween(strumLineNotes.members[3], {alpha: 0}, 1.1, {ease: FlxEase.sineInOut});
				case 4416:
					FlxTween.tween(strumLineNotes.members[0], {alpha: 0}, 1.1, {ease: FlxEase.sineInOut});
				case 4448:
					FlxTween.tween(strumLineNotes.members[1], {alpha: 0}, 1.1, {ease: FlxEase.sineInOut});

				case 4480:
					FlxTween.tween(strumLineNotes.members[6], {alpha: 0}, 1.1, {ease: FlxEase.sineInOut});
				case 4512:
					FlxTween.tween(strumLineNotes.members[7], {alpha: 0}, 1.1, {ease: FlxEase.sineInOut});
				case 4544:
					FlxTween.tween(strumLineNotes.members[4], {alpha: 0}, 1.1, {ease: FlxEase.sineInOut});
				case 4576:
					FlxTween.tween(strumLineNotes.members[5], {alpha: 0}, 1.1, {ease: FlxEase.sineInOut});
			}
		}
		//Midsong events for Termination (such as the sawblade attack)
		else if (curSong.toLowerCase() == 'extermination'){
				//For animating KB during the 404 section since he animates every half beat, not every beat.
			if(qtIsBlueScreened)
			{
				//Termination KB animates every 2 curstep instead of 4 (aka, every half beat, not every beat!)
				if (SONG.notes[Math.floor(curStep / 16)].mustHitSection && !dad404.animation.curAnim.name.startsWith("sing") && curStep % 2 == 0)
				{
					dad404.dance();
				}
			}

			//Making GF scared for error section
			if(curStep>=2816 && curStep<3328 && curStep % 2 == 0)
			{
				gf.playAnim('scared', true);
				if(!Main.qtOptimisation)
					gf404.playAnim('scared', true);
			}


			switch (curStep)
			{
				//Commented out stuff are for the double sawblade variations.
				//It is recommended to not uncomment them unless you know what you're doing. They are also not polished at all so don't complain about them if you do uncomment them.
				
				
				//CONVERTED THE CUSTOM INTRO FROM MODCHART INTO HARDCODE OR WHATEVER! NO MORE INVISIBLE NOTES DUE TO NO MODCHART SUPPORT!
				case 1:
					qt_tv01.animation.play("instructions_ALT");
					FlxTween.tween(strumLineNotes.members[0], {y: strumLineNotes.members[0].y + 10, alpha: 1}, 1.2, {ease: FlxEase.cubeOut});
					FlxTween.tween(strumLineNotes.members[7], {y: strumLineNotes.members[7].y + 10, alpha: 1}, 1.2, {ease: FlxEase.cubeOut});
					if(!Main.qtOptimisation){
						boyfriend404.alpha = 0; 
						dad404.alpha = 0;
						gf404.alpha = 0;
					}
					if(!Main.qtOptimisation){
						add(bgFlash);
						bg_RedFlash_Longer(true);
					}
				case 32:
					FlxTween.tween(strumLineNotes.members[1], {y: strumLineNotes.members[1].y + 10, alpha: 1}, 1.2, {ease: FlxEase.cubeOut});
					FlxTween.tween(strumLineNotes.members[6], {y: strumLineNotes.members[6].y + 10, alpha: 1}, 1.2, {ease: FlxEase.cubeOut});
					
					if(!Main.qtOptimisation){
						bg_RedFlash_Longer(true);
					}
				case 48:
					add(kb_attack_saw);
					add(kb_attack_alert);
					KBATTACK_ALERT();
					KBATTACK();
				case 52:
					KBATTACK_ALERT();
				case 56:
					KBATTACK(true);
				case 96:
					qt_tv01.animation.play("gl");
					FlxTween.tween(strumLineNotes.members[3], {y: strumLineNotes.members[3].y + 10, alpha: 1}, 1.2, {ease: FlxEase.cubeOut});
					FlxTween.tween(strumLineNotes.members[4], {y: strumLineNotes.members[4].y + 10, alpha: 1}, 1.2, {ease: FlxEase.cubeOut});
					if (!Main.qtOptimisation){
						bg_RedFlash_Critical_Longer(true);
					}
				case 64:
					FlxTween.tween(strumLineNotes.members[2], {y: strumLineNotes.members[2].y + 10, alpha: 1}, 1.2, {ease: FlxEase.cubeOut});
					FlxTween.tween(strumLineNotes.members[5], {y: strumLineNotes.members[5].y + 10, alpha: 1}, 1.2, {ease: FlxEase.cubeOut});
					if (!Main.qtOptimisation){
						bg_RedFlash_Critical_Longer(true);
					}
				case 112:
					KBATTACK_ALERT();
					KBATTACK();
				case 116:
					KBATTACK_ALERTDOUBLE();
				case 120:
					KBATTACK(true, "old/attack_alt01");
					for (boi in strumLineNotes.members) { //FAIL SAFE TO ENSURE THAT ALL THE NOTES ARE VISIBLE WHEN PLAYING!!!!!
						boi.alpha = 1;
					}
				case 123:
					KBATTACK();
				case 124:
				    //FlxTween.tween(strumLineNotes.members[0], {alpha: 0}, 2, {ease: FlxEase.sineInOut}); //for testing outro code
					KBATTACK(true, "old/attack_alt02");
				case 128:
					qt_tv01.animation.play("idle");
				case 1280:
					qt_tv01.animation.play("idle");
				case 480:
					qt_tv01.animation.play("watch");
				case 516:
					qt_tv01.animation.play("idle");

				case 272 | 304 | 404 | 416 | 504 | 544 | 560 | 612 | 664 | 696 | 752 | 816 | 868 | 880 | 1088 | 1204 | 1344 | 1400 | 1428 | 1440 | 1472 | 1520 | 1584 | 1648 | 1680 | 1712 | 1744:
					KBATTACK_ALERT();
					KBATTACK();
				case 276 | 308 | 408 | 420 | 508 | 548 | 564 | 616 | 668 | 700 | 756 | 820 | 872 | 884 | 1092 | 1208 | 1348 | 1404 | 1432 | 1444 | 1476 | 1524 | 1588 | 1652 | 1684 | 1716 | 1748: 
					KBATTACK_ALERT();
				case 280 | 312 | 412 | 424 | 512 | 552 | 568 | 620 | 672 | 704 | 760 | 824 | 876 | 888 | 1096 | 1212 | 1352 | 1408 | 1436 | 1448 | 1480 | 1528 | 1592 | 1656 | 1688 | 1720 | 1752:
					KBATTACK(true);

				case 1776 | 1904 | 2576 | 2596 | 2624 | 2640 | 2660 | 2704 | 2736 | 3072 | 3104 | 3136 | 3152 | 3168 | 3184 | 3216 | 3248 | 3312:
					KBATTACK_ALERT();
					KBATTACK();
				case 1780 | 1908 | 2580 | 2600 | 2628 | 2644 | 2664 | 2708 | 2740 | 3076 | 3108 | 3140 | 3156 | 3172 | 3188 | 3220 | 3252 | 3316:
					KBATTACK_ALERT();
				case 1784 | 1912 | 2584 | 2604 | 2632 | 2648 | 2668 | 2712 | 2744 | 3080 | 3112 | 3144 | 3160 | 3176 | 3192 | 3224 | 3256 | 3320:
					KBATTACK(true);

				case 1808 | 1840 | 1872 | 1952 | 2000 | 2112 | 2148 | 2176 | 2192 | 2228 | 2240 | 2272 | 2768 | 2788 | 2800 | 2864 | 2916 | 2928 | 3032 | 3264 | 3280 | 3300:
					KBATTACK_ALERT();
					KBATTACK();
				case 1812 | 1844 | 1876 | 1956 | 2004 | 2116 | 2152 | 2180 | 2196 | 2232 | 2244 | 2276 | 2772 | 2792 | 2804 | 2868 | 2920 | 2932 | 3036 | 3268 | 3284 | 3304:
					KBATTACK_ALERT();
				case 1816 | 1848 | 1880 | 1960 | 2008 | 2120 | 2156 | 2184 | 2200 | 2236 | 2248 | 2280 | 2776 | 2796 | 2872 | 2924 | 2936 | 3040 | 3272 | 3288 | 3308:
					KBATTACK(true);

                case 624 | 1136 | 2032 | 2608 | 2672 | 3084 | 3116 | 3696 | 4464:
					KBATTACK_ALERT();
					KBATTACK();
				case 628 | 1140 | 2036 | 2612 | 2676 | 3088 | 3120 | 3700 | 4468:
					KBATTACK_ALERTDOUBLE();
				case 632 | 1144 | 2040 | 2616 | 2680 | 3092 | 3124 | 3704 | 4472:
					KBATTACK(true, "old/attack_alt01");
				case 635 | 1147 | 2043 | 2619 | 2683 | 3095 | 3127 | 3707 | 4151 | 4215 | 4347 | 4475:
					KBATTACK();
				case 636 | 1148 | 2044 | 2620 | 2684 | 3096 | 3128 | 3708 | 4476:
					KBATTACK(true, "old/attack_alt02");
				//Sawblades before bluescreen thing
				//These were seperated for double sawblade experimentation if you're wondering.
				//My god this organisation is so bad. Too bad!
				//Yes, this is too bad! -DrkFon376
				case 2304 | 2320 | 2340 | 2368 | 2384 | 2404 | 2496 | 2528:
					KBATTACK_ALERT();
					KBATTACK();
				case 2308 | 2324 | 2344 | 2372 | 2388 | 2408 | 2500 | 2532:
					KBATTACK_ALERT();
				case 2312 | 2328 | 2348 | 2376 | 2392 | 2412 | 2504 | 2536:
					KBATTACK(true);

				case 2352 | 2416:
					KBATTACK_ALERT();
					KBATTACK();
				case 2356 | 2420:
					KBATTACK_ALERTDOUBLE();
				case 2360 | 2424:
					KBATTACK(true, "old/attack_alt01");
				case 2363 | 2427:
					KBATTACK();
				case 2364 | 2428:
					KBATTACK(true, "old/attack_alt02");

				case 2560:
					KBATTACK_ALERT();
					KBATTACK();
					qt_tv01.animation.play("eye");
				case 2564:
					KBATTACK_ALERT();
				case 2568:
					KBATTACK(true);
				
				case 2808:
					//Change to glitch background
					if(!Main.qtOptimisation){
						streetBGerror.visible = true;
						streetBG.visible = false;
					}
					FlxG.camera.shake(0.0075,0.675);
					qt_tv01.animation.play("error");

					KBATTACK(true);
	
				case 2816: //404 section
					qt_tv01.animation.play("404");
					gfSpeed = 1;
					//Change to bluescreen background
					if(!Main.qtOptimisation){
						streetBG.visible = false;
						streetBGerror.visible = false;
						streetFrontError.visible = true;
						qtIsBlueScreened = true;
						CensoryOverload404();
					}
				case 3328: //Final drop
					qt_tv01.animation.play("alert");
					gfSpeed = 1;
					//Revert back to normal
					if(!Main.qtOptimisation){
						streetBG.visible = true;
						streetFrontError.visible = false;
						qtIsBlueScreened = false;
						CensoryOverload404();
					}
				case 3840 | 3844 | 3848 | 3852 | 3856 | 3860 | 3864 | 3868 | 3884 | 3900 | 3904 | 3908 | 3912 | 3916 | 3920 | 3948 | 3964 | 3968 | 3972 | 3976 | 3980 | 3996 | 4000 | 4004 | 4008 | 4012 | 4016 | 4044 | 4048 | 4052 | 4056 | 4060 | 4088 | 4092:
					if (!Main.qtOptimisation){
						bg_RedFlash(true);
					}
				case 3872 | 3888 | 3924 | 3936 | 3952 | 3984 | 4020 | 4032 | 4064 | 4076:
					KBATTACK_ALERT();
					KBATTACK();
					if (!Main.qtOptimisation){
						bg_RedFlash(true);
					}
				case 3876 | 3892 | 3928 | 3940 | 3956 | 3988 | 4024 | 4036 | 4068 | 4080:
					KBATTACK_ALERT();
					if (!Main.qtOptimisation){
						bg_RedFlash(true);
					}
				case 3880 | 3896 | 3932 | 3944 | 3960 | 3992 | 4028 | 4040 | 4072 | 4084:
					KBATTACK(true);
					if (!Main.qtOptimisation){
						bg_RedFlash(true);
					}
				case 4120 | 4124 | 4156 | 4172 | 4188 | 4220 | 4236 | 4240 | 4244 | 4248 | 4252 | 4280 | 4284 | 4300 | 4304 | 4308 | 4312 | 4316 | 4320:
					if (!Main.qtOptimisation){
						bg_RedFlash_Critical(true);
					}
				case 4096 | 4108 | 4128 | 4140 | 4160 | 4176 | 4192 | 4204 | 4224 | 4256 | 4268 | 4288 | 4324 | 4336:
					KBATTACK_ALERT();
					KBATTACK();
					if (!Main.qtOptimisation){
						bg_RedFlash_Critical(true);
					}
				case 4100 | 4112 | 4132 | 4164 | 4180 | 4196 | 4228 | 4260 | 4272 | 4292 | 4328:
					KBATTACK_ALERT();
					if (!Main.qtOptimisation){
						bg_RedFlash_Critical(true);
					}
				case 4144 | 4208 | 4340: 
					KBATTACK_ALERTDOUBLE();
					if (!Main.qtOptimisation){
						bg_RedFlash_Critical(true);
					}
				case 4104 | 4116 | 4136 | 4168 | 4184 | 4200 | 4232 | 4264 | 4276 | 4296 | 4332:
					KBATTACK(true);
					if (!Main.qtOptimisation){
						bg_RedFlash_Critical(true);
					}
				case 4148 | 4212 | 4344:
					KBATTACK(true, "old/attack_alt01");
					if (!Main.qtOptimisation){
						bg_RedFlash_Critical(true);
					}
				case 4152 | 4216 | 4348:
					KBATTACK(true, "old/attack_alt02");
					if (!Main.qtOptimisation){
						bg_RedFlash_Critical(true);
					}
				case 3360 | 3376 | 3396 | 3408 | 3424 | 3440 | 3504 | 3552 | 3576 | 3616 | 3636 | 3648 | 3664 | 3680 | 3776 | 3808 | 3824:
					KBATTACK_ALERT();
					KBATTACK();
				case 3364 | 3380 | 3400 | 3412 | 3428 | 3444 | 3508 | 3556 | 3580 | 3620 | 3640 | 3652 | 3668 | 3684 | 3780 | 3812 | 3828:
					KBATTACK_ALERT();
				case 3368 | 3384 | 3404 | 3416 | 3432 | 3448 | 3512 | 3560 | 3584 | 3624 | 3644 | 3656 | 3672 | 3688 | 3784 | 3816 | 3832:
					KBATTACK(true);

				case 4368 | 4400 | 4432 | 4496 | 4528 | 4560 | 4592 | 4688:
					KBATTACK_ALERT();
					KBATTACK();
				case 4372 | 4404 | 4436 | 4500 | 4532 | 4564 | 4596 | 4692:
					KBATTACK_ALERT();
				case 4376 | 4408 | 4440 | 4504 | 4536 | 4568 | 4600 | 4696://<----LMFAO this is the last sawblade placed on the last beat of the level. Funny, right? 
					KBATTACK(true);
								
				case 4352: //Custom outro hardcoded instead of being part of the modchart! 
					qt_tv01.animation.play("idle");
					FlxTween.tween(strumLineNotes.members[2], {alpha: 0}, 1.1, {ease: FlxEase.sineInOut});
				case 4384:
					FlxTween.tween(strumLineNotes.members[3], {alpha: 0}, 1.1, {ease: FlxEase.sineInOut});
				case 4416:
					FlxTween.tween(strumLineNotes.members[0], {alpha: 0}, 1.1, {ease: FlxEase.sineInOut});
				case 4448:
					FlxTween.tween(strumLineNotes.members[1], {alpha: 0}, 1.1, {ease: FlxEase.sineInOut});

				case 4480:
					FlxTween.tween(strumLineNotes.members[6], {alpha: 0}, 1.1, {ease: FlxEase.sineInOut});
				case 4512:
					FlxTween.tween(strumLineNotes.members[7], {alpha: 0}, 1.1, {ease: FlxEase.sineInOut});
				case 4544:
					FlxTween.tween(strumLineNotes.members[4], {alpha: 0}, 1.1, {ease: FlxEase.sineInOut});
				case 4576:
					FlxTween.tween(strumLineNotes.members[5], {alpha: 0}, 1.1, {ease: FlxEase.sineInOut});
			}		
		}
		else if (curSong.toLowerCase() == 'expurgation' && curStep != stepOfLast){
			//For animating KB during the 404 section since he animates every half beat, not every beat.
			if(qtIsBlueScreened)
				{
					if (SONG.notes[Math.floor(curStep / 16)].mustHitSection && !dad404.animation.curAnim.name.startsWith("sing") && curStep % 2 == 0)
					{
						dad404.dance();
					}
				}
			//Making GF scared for error section
			if(curStep>=2144 && curStep<2656 && curStep % 2 == 0)
				{
					gf.playAnim('scared', true);
					if(!Main.qtOptimisation)
						gf404.playAnim('scared', true);
				}
			switch (curStep)
			{
				case 1:
					qt_tv01.animation.play("instructions");
					if(!Main.qtOptimisation){
						boyfriend404.alpha = 0; 
						dad404.alpha = 0;
						gf404.alpha = 0;
					}
				case 64:
					qt_tv01.animation.play("gl");
					add(kb_attack_saw);
					add(kb_attack_alert);
					KBATTACK_ALERT();
					KBATTACK();
				case 68:
					KBATTACK_ALERT();
				case 72:
					KBATTACK(true);
				case 96:
					qt_tv01.animation.play("idle");
				/*case 128:
					//Experimental stuff
					qt_tv01.animation.play("404");
						if(!Main.qtOptimisation){
							streetBG.visible = false;
							streetBGerror.visible = false;
							streetFrontError.visible = true;
							qtIsBlueScreened = true;
							sign.animation.play('bluescreen');
							CensoryOverload404();
						}*/
				case 448:
					qt_tv01.animation.play("eye");
					KBATTACK_ALERT();
					KBATTACK();
				case 352 | 368 | 484 | 496 | 560 | 644 | 712 | 728 | 768 | 816 | 896 | 928 | 944 | 1156 | 1168 | 1248 | 1264 | 1284 | 1296 | 1344 | 1392 | 1412 | 1424 | 1536 | 1552 | 1616 | 1744 | 1808 | 1872 | 1920 | 1972 | 1984 | 2052 | 2064:
					KBATTACK_ALERT();
					KBATTACK();
				case 356 | 372 | 452 | 488 | 500 | 564 | 612 | 648 | 716 | 732 | 772 | 820 | 900 | 932 | 948 | 1160 | 1172 | 1252 | 1268 | 1288 | 1300 | 1348 | 1396 | 1416 | 1428 | 1540 | 1556 | 1588 | 1620 | 1748 | 1812 | 1876 | 1924 | 1976 | 1988 | 2020 | 2056 | 2068:
					KBATTACK_ALERT();
				case 360 | 376 | 456 | 492 | 504 | 568 | 616 | 652 | 736 | 776 | 824 | 904 | 936 | 952 | 1164 | 1176 | 1256 | 1272 | 1292 | 1304 | 1352 | 1400 | 1420 | 1432 | 1544 | 1560 | 1592 | 1624 | 1752 | 1816 | 1880 | 1928 | 1980 | 1992 | 2024 | 2060 | 2072:
					KBATTACK(true);
				case 384:
					doStopSign(0);
				case 511:
					doStopSign(2);
					doStopSign(0);
				case 576:
					qt_tv01.animation.play("sus");//That's kinda sussy
				case 608:
					qt_tv01.animation.play("idle");
					KBATTACK_ALERT();
					KBATTACK();
				case 610:
					doStopSign(3);
				case 720:
					doStopSign(2);
					KBATTACK(true);
				case 991:
					doStopSign(3);
				case 1120:
					qt_tv01.animation.play("idle");
				case 1184:
					doStopSign(2);
				case 1218:
					doStopSign(0);
				case 1235:
					doStopSign(0, true);
				case 1200:
					doStopSign(3);
				case 1328:
					doStopSign(0, true);
					doStopSign(2);
				case 1376:
					qt_tv01.animation.play("eye");
				case 1439:
					doStopSign(3, true);
				case 1567:
					doStopSign(0);
				case 1584:
					doStopSign(0, true);
					KBATTACK_ALERT();
					KBATTACK();
				case 1600:
					doStopSign(2);
				case 1632:
					qt_tv01.animation.play("idle");
				case 1706:
					doStopSign(3);
				case 1888:
					qt_tv01.animation.play("eye");
				case 1917:
					doStopSign(0);
				case 1923:
					doStopSign(0, true);
				case 1927:
					doStopSign(0);
				case 1932:
					doStopSign(0, true);
				case 2016:
					qt_tv01.animation.play("idle");
					KBATTACK_ALERT();
					KBATTACK();
				case 2032:
					doStopSign(2);
					doStopSign(0);
				case 2036:
					doStopSign(0, true);
				case 2096:
					defaultCamZoom = 0.75;
				case 2098:
					defaultCamZoom = 0.775;
				case 2100:
					defaultCamZoom = 0.8;
				case 2102:
					defaultCamZoom = 0.825;
				case 2104:
					defaultCamZoom = 0.85;
				case 2106:
					defaultCamZoom = 0.875;
				case 2108:
					defaultCamZoom = 0.9;
				case 2110:
					defaultCamZoom = 0.925;
				case 2112:
					defaultCamZoom = 0.95;
				case 2114:
					defaultCamZoom = 0.975;
				case 2116:
					defaultCamZoom = 1.0;
				case 2118:
					defaultCamZoom = 1.025;
				case 2120:
					defaultCamZoom = 1.05;
				case 2122:
					defaultCamZoom = 1.075;
				case 2124:
					defaultCamZoom = 1.1;
				case 2126:
					defaultCamZoom = 1.125;
				case 2128:
					defaultCamZoom = 0.725;
					if(!Main.qtOptimisation){
						streetBGerror.visible = true;
						streetBG.visible = false;
					}
					FlxG.camera.shake(0.02,1.05);
					qt_tv01.animation.play("error");
				case 2144:
					qt_tv01.animation.play("404");
						if(!Main.qtOptimisation){
							streetBG.visible = false;
							streetBGerror.visible = false;
							streetFrontError.visible = true;
							qtIsBlueScreened = true;
							sign.animation.play('bluescreen');
							CensoryOverload404();
						}
				//Sawblades during and after the bluescreen.
				case 2208 | 2264 | 2288 | 2340 | 2352 | 2400 | 2436 | 2464 | 2500 | 2580 | 2592 | 2624 | 2640 | 2672 | 2724 | 2736 | 2784 | 2796 | 2832 | 2848 | 2868 | 2880 | 2896:
					KBATTACK_ALERT();
					KBATTACK();
				case 2212 | 2268 | 2292 | 2344 | 2356 | 2404 | 2440 | 2468 | 2504 | 2516 | 2548 | 2584 | 2596 | 2628 | 2644 | 2676 | 2728 | 2740 | 2788 | 2800 | 2836 | 2852 | 2872 | 2884 | 2900:
					KBATTACK_ALERT();
				case 2216 | 2272 | 2296 | 2348 | 2360 | 2408 | 2444 | 2472 | 2508 | 2520 | 2552 | 2588 | 2600 | 2632 | 2648 | 2680 | 2732 | 2744 | 2792 | 2804 | 2840 | 2856 | 2876 | 2888 | 2904:
					KBATTACK(true);
				case 2162:
					doStopSign(2);
					doStopSign(3);
				case 2193:
					doStopSign(0);
				case 2202:
					doStopSign(0,true);
				case 2239:
					doStopSign(2,true);
				case 2258:
					doStopSign(0, true);
				case 2304:
					doStopSign(0, true);
					doStopSign(0);	
				case 2326:
					doStopSign(0, true);
				case 2336:
					doStopSign(3);
				case 2447:
					doStopSign(2);
					doStopSign(0, true);
					doStopSign(0);	
				case 2480:
					doStopSign(0, true);
					doStopSign(0);	
				case 2512:
					doStopSign(2);
					doStopSign(0, true);
					doStopSign(0);
					KBATTACK_ALERT();
					KBATTACK();
				case 2544:
					doStopSign(0, true);
					doStopSign(0);
					KBATTACK_ALERT();
					KBATTACK();
				case 2575:
					doStopSign(2);
					doStopSign(0, true);
					doStopSign(0);
				case 2608:
					doStopSign(0, true);
					doStopSign(0);	
				case 2604:
					doStopSign(0, true);
				case 2655:
					doGremlin(20,13,true);
				case 2656:
					qt_tv01.animation.play("idle");
					gfSpeed = 1;
					//Revert back to normal
					if(!Main.qtOptimisation){
						streetBG.visible = true;
						streetFrontError.visible = false;
						qtIsBlueScreened = false;
						sign.animation.play('normal');
						CensoryOverload404();			
					}
			}
			stepOfLast = curStep;
		}
		else if (curSong.toLowerCase() == 'milf'){//HOLY SHIT MILF WITH SAWBLADES???
			switch (curStep)
			{
				case 1:
					dodgeTimingOverride(0.275);
					dodgeCooldownOverride(0);
				case 32:
					add(kb_attack_saw);
					add(kb_attack_alert);
					KBATTACK_ALERT();
					KBATTACK();
				case 36:
					KBATTACK_ALERT();
				case 40:
					KBATTACK(true);
				case 208 | 288 | 324 | 336 | 428 | 448 | 464 | 584 | 656:
					KBATTACK_ALERT();
					KBATTACK();
				case 212 | 292 | 328 | 340 | 432 | 452 | 468 | 588 | 660:
					KBATTACK_ALERT();
				case 216 | 296 | 332 | 344 | 436 | 456 | 472 | 592 | 664:
					KBATTACK(true);
				case 672:
					//bfDodging = true; //If you uncomment this, BF won't need to dodge the sawblade.
					dodgeTimingOverride(0.15);
					dodgeCooldownOverride(0.09225);
					KBATTACK_ALERT();
					KBATTACK();
				case 674:
					KBATTACK_ALERT();
				case 676:
					KBATTACK(true);
				case 678 | 688 | 694:
					KBATTACK_ALERT();
					KBATTACK();
				case 680 | 690 | 696:
					KBATTACK_ALERT();
				case 682 | 692 | 698:
					KBATTACK(true);
				//OH SHIT
				case 704:
					KBATTACK_ALERT();
					KBATTACK();
				case 706 | 710 | 714 | 718 | 722 | 726 | 730 | 734:
					KBATTACK_ALERT();
				case 708 | 712 | 716 | 720 | 724 | 728 | 732:
					KBATTACK(true);
					KBATTACK_ALERT();
				case 711 | 715 | 719 | 723 | 727 | 731:
					KBATTACK();
				//bf drop part
				case 744:
					dodgeTimingOverride(0.275);
					dodgeCooldownOverride(0.1135);
				case 752 | 764:
					KBATTACK_ALERT();
					KBATTACK();
				case 756 | 768:
					KBATTACK_ALERT();
				case 760:
					KBATTACK(true);
				case 776 | 784 | 792:
					KBATTACK_ALERT();
					KBATTACK();
				case 772 | 780 | 788 | 796:
					KBATTACK(true);
					KBATTACK_ALERT();
				//Sawblades after the drop
				case 800:
					//bfDodging = false; //If you uncomment this, BF will need to dodge the sawblade again.
				case 836 | 848 | 920 | 948 | 976 | 996 | 1024 | 1056 | 1070 | 1088 | 1108 | 1120 | 1152 | 1176 | 1216 | 1232 | 1288 | 1312 | 1334 | 1350 | 1366 | 1398 | 1420 | 1432:
					KBATTACK_ALERT();
					KBATTACK();
				case 840 | 852 | 924 | 952 | 980 | 1000 | 1028 | 1060 | 1074 | 1092 | 1112 | 1124 | 1156 | 1180 | 1220 | 1236 | 1292 | 1316 | 1338 | 1354 | 1370 | 1402 | 1424 | 1436:
					KBATTACK_ALERT();
				case 844 | 856 | 928 | 956 | 984 | 1004 | 1032 | 1064 | 1078 | 1096 | 1116 | 1128 | 1160 | 1184 | 1224 | 1240 | 1296 | 1320 | 1342 | 1358 | 1374 | 1406 | 1428 | 1440:
					KBATTACK(true);
			}
		}
		//????
		else if (curSong.toLowerCase() == 'redacted'){
			switch (curStep)
			{
				case 1:
					boyfriend404.alpha = 0.0125;
				case 16:
					FlxTween.tween(strumLineNotes.members[4], {y: strumLineNotes.members[4].y + 10, alpha: 0.8}, 6, {ease: FlxEase.circOut});
				case 20:
					FlxTween.tween(strumLineNotes.members[5], {y: strumLineNotes.members[5].y + 10, alpha: 0.8}, 6, {ease: FlxEase.circOut});
				case 24:
					FlxTween.tween(strumLineNotes.members[6], {y: strumLineNotes.members[6].y + 10, alpha: 0.8}, 6, {ease: FlxEase.circOut});
				case 28:
					FlxTween.tween(strumLineNotes.members[7], {y: strumLineNotes.members[7].y + 10, alpha: 0.8}, 6, {ease: FlxEase.circOut});

				case 584:
					add(kb_attack_alert);
					kb_attack_alert.animation.play('alert'); //Doesn't call function since this alert is unique + I don't want sound lmao since it's already in the inst
				case 588:
					kb_attack_alert.animation.play('alert');
				case 600 | 604 | 616 | 620 | 632 | 636 | 648 | 652 | 664 | 668 | 680 | 684 | 696 | 700:
					kb_attack_alert.animation.play('alert');
				case 704:
					qt_tv01.animation.play("part1");
					FlxTween.tween(strumLineNotes.members[0], {y: strumLineNotes.members[0].y + 10, alpha: 0.1125}, 25, {ease: FlxEase.circOut});
					FlxTween.tween(strumLineNotes.members[1], {y: strumLineNotes.members[1].y + 10, alpha: 0.1125}, 25, {ease: FlxEase.circOut});
					FlxTween.tween(strumLineNotes.members[2], {y: strumLineNotes.members[2].y + 10, alpha: 0.1125}, 25, {ease: FlxEase.circOut});
					FlxTween.tween(strumLineNotes.members[3], {y: strumLineNotes.members[3].y + 10, alpha: 0.1125}, 25, {ease: FlxEase.circOut});
				case 752:
					qt_tv01.animation.play("part2");
				case 800:
					qt_tv01.animation.play("part3");
				case 832:
					qt_tv01.animation.play("part4");
				case 1216:
					qt_tv01.animation.play("idle");
					qtIsBlueScreened = true; //Reusing the 404bluescreen code for swapping BF character.
					boyfriend.alpha = 0;
					boyfriend404.alpha = 1;
					iconP1.animation.play("bf");										
			}
		}
		else if (curSong.toLowerCase() == 'extermination'){
			if(qtIsBlueScreened)
				{
					//Termination KB animates every 2 curstep instead of 4 (aka, every half beat, not every beat!)
					if (SONG.notes[Math.floor(curStep / 16)].mustHitSection && !dad404.animation.curAnim.name.startsWith("sing") && curStep % 2 == 0)
					{
						dad404.dance();
					}
				}
		}
		else if (curSong.toLowerCase() == 'expurgation'){
			if(qtIsBlueScreened)
				{
					//Termination KB animates every 2 curstep instead of 4 (aka, every half beat, not every beat!)
					if (SONG.notes[Math.floor(curStep / 16)].mustHitSection && !dad404.animation.curAnim.name.startsWith("sing") && curStep % 2 == 0)
					{
						dad404.dance();
					}
				}
		}

		// yes this updates every step.
		// yes this is bad
		// but i'm doing it to update misses and accuracy

		//for events like shaders
		switch (SONG.song.toLowerCase()) 
		{

			/* 

			// example of using chromatic aberration shaders
			case 'milf':
				switch (curStep)
				{
					case 512:
						chromOn = true;
					case 1024:
						chromOn = false;
				}
			*/

			default:
				// nothing lmao

		}

		#if windows
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") ", "Misses:" + misses + " | " + "Score:" + songScore + " | " + "KPS:" + kps + "(" + kpsMax + ")" + " | " + "Accuracy:" + totalAccuracy + "%" + " | " + "Rank:" + totalRank, iconRPC,true,  songLength - Conductor.songPosition);
		#end
	}
	
	var totalDamageTaken:Float = 0;

	var shouldBeDead:Bool = false;

	var interupt = false;
	
	function doGremlin(hpToTake:Int, duration:Int,persist:Bool = false)
	{
		interupt = false;
	
		grabbed = true;
			
		totalDamageTaken = 0;
	
		var gramlan:FlxSprite = new FlxSprite(0,0);
	
		gramlan.frames = Paths.getSparrowAtlas('HP GREMLIN');
	
		gramlan.setGraphicSize(Std.int(gramlan.width * 0.76));
	
		gramlan.cameras = [camHUD];
	
		gramlan.x = iconP1.x;
		gramlan.y = healthBarBG.y - 325;
	
		gramlan.animation.addByIndices('come','HP Gremlin ANIMATION',[0,1], "", 24, false);
		gramlan.animation.addByIndices('grab','HP Gremlin ANIMATION',[2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24], "", 24, false);
		gramlan.animation.addByIndices('hold','HP Gremlin ANIMATION',[25,26,27,28],"",24);
		gramlan.animation.addByIndices('release','HP Gremlin ANIMATION',[29,30,31,32,33],"",24,false);
	
		gramlan.antialiasing = true;
	
		add(gramlan);
	
		if(FlxG.save.data.downscroll){
			gramlan.flipY = true;
			gramlan.y -= 150;
		}
			
		// over use of flxtween :)
	
		var startHealth = health;
		var toHealth = (hpToTake / 100) * startHealth; // simple math, convert it to a percentage then get the percentage of the health
	
		var perct = toHealth / 2 * 100;
	
		trace('start: $startHealth\nto: $toHealth\nwhich is prect: $perct');
	
		var onc:Bool = false;
	
		FlxG.sound.play(Paths.sound('GremlinWoosh'));
	
		gramlan.animation.play('come');
		new FlxTimer().start(0.14, function(tmr:FlxTimer) {
			gramlan.animation.play('grab');
			FlxTween.tween(gramlan,{x: iconP1.x - 140},1,{ease: FlxEase.elasticIn, onComplete: function(tween:FlxTween) {
				trace('I got em');
				gramlan.animation.play('hold');
				FlxTween.tween(gramlan,{
					x: (healthBar.x + 
					(healthBar.width * (FlxMath.remapToRange(perct, 0, 100, 100, 0) * 0.01) 
					- 26)) - 75}, duration,
				{
					onUpdate: function(tween:FlxTween) { 
						// lerp the health so it looks pog
						if (interupt && !onc && !persist)
						{
							onc = true;
							trace('oh shit');
							gramlan.animation.play('release');
							gramlan.animation.finishCallback = function(pog:String) { gramlan.alpha = 0;}
						}
						else if (!interupt || persist)
						{
							var pp = FlxMath.lerp(startHealth,toHealth, tween.percent);
							if (pp <= 0)
								pp = 0.1;
							health = pp;
						}

						if (shouldBeDead)
							health = 0;
					},
					onComplete: function(tween:FlxTween)
					{
						if (interupt && !persist)
						{
							remove(gramlan);
							grabbed = false;
						}
						else
						{
							trace('oh shit');
							gramlan.animation.play('release');
							if (persist && totalDamageTaken >= 0.7)
								health -= totalDamageTaken; // just a simple if you take a lot of damage wtih this, you'll loose probably.
							gramlan.animation.finishCallback = function(pog:String) { remove(gramlan);}
							grabbed = false;
						}
					}
				});
			}});
		});
	}

	function doStopSign(sign:Int = 0, fuck:Bool = false)
		{
			trace('sign ' + sign);
			var daSign:FlxSprite = new FlxSprite(0,0);
			// CachedFrames.cachedInstance.get('sign')
	
			daSign.frames = Paths.getSparrowAtlas('Sign_Post_Mechanic', 'preload');
	
			daSign.setGraphicSize(Std.int(daSign.width * 0.67));
	
			daSign.cameras = [camHUD];
	
			switch(sign)
			{
				case 0:
					daSign.animation.addByPrefix('sign','Signature Stop Sign 1',24, false);
					daSign.x = FlxG.width - 650;
					daSign.angle = -90;
					daSign.y = -300;
				case 1:
					/*daSign.animation.addByPrefix('sign','Signature Stop Sign 2',20, false);
					daSign.x = FlxG.width - 670;
					daSign.angle = -90;*/ // this one just doesn't work???
				case 2:
					daSign.animation.addByPrefix('sign','Signature Stop Sign 3',24, false);
					daSign.x = FlxG.width - 780;
					daSign.angle = -90;
					if (FlxG.save.data.downscroll)
						daSign.y = -395;
					else
						daSign.y = -980;
				case 3:
					daSign.animation.addByPrefix('sign','Signature Stop Sign 4',24, false);
					daSign.x = FlxG.width - 1070;
					daSign.angle = -90;
					daSign.y = -145;
			}
			add(daSign);
			daSign.flipX = fuck;
			daSign.animation.play('sign');
			daSign.animation.finishCallback = function(pog:String)
				{
					trace('ended sign');
					remove(daSign);
				}
		}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	//some effects
	public function spinHudCamera()
	{
		camHUD.angle = camHUD.angle + (!spinCamHudLeft ? spinCamHudSpeed : spinCamHudSpeed / -1) / 1;
	}
	public function spinGameCamera()
	{
		camGame.angle = camGame.angle + (!spinCamGameLeft ? spinCamGameSpeed : spinCamGameSpeed / -1) / 1;
	}
	public function spinPlayerStrumLineNotes()
	{
		playerStrums.forEach(function(spr:FlxSprite)
			{
				spr.angle = spr.angle + (!spinPlayerNotesLeft ? spinPlayerNotesSpeed : spinPlayerNotesSpeed / -1) / 1 * (spr.ID + 2);
			});
	}
	public function spinEnemyStrumLineNotes()
	{
		dadStrums.forEach(function(spr:FlxSprite)
			{
				spr.angle = spr.angle + (!spinEnemyNotesLeft ? spinEnemyNotesSpeed : spinEnemyNotesSpeed / -1) / 1 * (spr.ID + 2);
			});
	}

	public function changeDadCharacter(char:String = "dad")
	{
		var oldDadX:Float = dad.x;
		var oldDadY:Float = dad.y;
		oldDadY = dad.y;
		oldDadX = dad.x;
		remove(dad);
        	dad.destroy();
        	dad = new Character(oldDadX,oldDadY,char);
        	add(dad);
	}

	public function changeAllCharacters(charDad:String = "dad", charGf:String = "gf", charBf:String = "bf")
	{
		changeGFCharacter(charGf);
		changeDadCharacter(charDad);
		changeBFCharacter(charBf);
	}

	public function changeGFCharacter(char:String = "gf")
	{
		var oldGFX:Float = gf.x;
		var oldGFY:Float = gf.y;
		oldGFY = gf.y;
		oldGFX = gf.x;
		remove(gf);
        	gf.destroy();
        	gf = new Character(oldGFX,oldGFY,char);
        	add(gf);
	}

	public function changeBFCharacter(char:String = "bf")
	{
		var oldBfX:Float = boyfriend.x;
		var oldBfY:Float = boyfriend.y;
		oldBfY = boyfriend.y;
		oldBfX = boyfriend.x;
		remove(boyfriend);
        	boyfriend.destroy();
        	boyfriend = new Boyfriend(oldBfX,oldBfY,char);
        	add(boyfriend);
	}

	var cameraBeatSpeed:Int = 4;
	var cameraBeatZoom:Float = 0.015;

	override function beatHit()
	{
		super.beatHit();
		
			/*if (SONG.notes[Math.floor(curStep / 16)].mustHitSection && !qtCarelessFin){
				if(SONG.song.toLowerCase() == "cessation"){
					if((curStep >= 640 && curStep <= 794) || (curStep >= 1040 && curStep <= 1199))
					{
						dad.dance(true);
					}else{
						dad.dance();
					}
				}
				else
					dad.dance();
			}

		}*/

		// Copy and pasted the milf code above for censory overload -Haz
		if (curSong.toLowerCase() == 'censory-overload')
		{

			if(curBeat >= 80 && curBeat <= 208) //first drop
			{
				//Gas Release effect
				if (curBeat % 16 == 0 && !Main.qtOptimisation)
				{
					qt_gas01.animation.play('burst');
					qt_gas02.animation.play('burst');
				}
			}
			else if(curBeat >= 304 && curBeat <= 432) //second drop
			{
				if(camZooming && FlxG.camera.zoom < 1.35)
				{
					FlxG.camera.zoom += 0.0075;
					camHUD.zoom += 0.015;
				}
				if(!(curBeat == 432)) //To prevent alert flashing when I don't want it too.
					qt_tv01.animation.play("alert");

				//Gas Release effect
				if (curBeat % 8 == 0 && !Main.qtOptimisation)
				{
					qt_gas01.animation.play('burstALT');
					qt_gas02.animation.play('burstALT');
				}
			}
			else if(curBeat >= 560 && curBeat <= 688){ //third drop
				if(camZooming && FlxG.camera.zoom < 1.35)
				{
					FlxG.camera.zoom += 0.0075;
					camHUD.zoom += 0.015;
				}
				//Gas Release effect
				if (curBeat % 4 == 0 && !Main.qtOptimisation)
				{
					qt_gas01.animation.play('burstFAST');
					qt_gas02.animation.play('burstFAST');
				}
			}
			else if(curBeat >= 832 && curBeat <= 960){ //final drop
				if(camZooming && FlxG.camera.zoom < 1.35)
				{
					FlxG.camera.zoom += 0.0075;
					camHUD.zoom += 0.015;
				}
				if(!(curBeat == 960)) //To prevent alert flashing when I don't want it too.
					qt_tv01.animation.play("alert");
				//Gas Release effect
				if (curBeat % 4 == 2 && !Main.qtOptimisation)
				{
					qt_gas01.animation.play('burstFAST');
					qt_gas02.animation.play('burstFAST');
				}
			}
			else if((curBeat == 976 || curBeat == 992) && camZooming && FlxG.camera.zoom < 1.35){ //Extra zooms for distorted kicks at end
				FlxG.camera.zoom += 0.031;
				camHUD.zoom += 0.062;
			}else if(curBeat == 702 && !Main.qtOptimisation){
				qt_gas01.animation.play('burst');
				qt_gas02.animation.play('burst');}
			
		}
		else if(SONG.song.toLowerCase() == "termination" || SONG.song.toLowerCase() == "extermination"){
			if(curBeat >= 192 && curBeat <= 320) //1st drop
			{
				if(camZooming && FlxG.camera.zoom < 1.35)
				{
					FlxG.camera.zoom += 0.0075;
					camHUD.zoom += 0.015;
				}
				if(!(curBeat == 320)) //To prevent alert flashing when I don't want it too.
					qt_tv01.animation.play("alert");
			}
			else if(curBeat >= 512 && curBeat <= 640) //1st drop
			{
				if(camZooming && FlxG.camera.zoom < 1.35)
				{
					FlxG.camera.zoom += 0.0075;
					camHUD.zoom += 0.015;
				}
				if(!(curBeat == 640)) //To prevent alert flashing when I don't want it too.
					qt_tv01.animation.play("alert");
			}
			else if(curBeat >= 832 && curBeat <= 1088) //last drop
				{
					if(camZooming && FlxG.camera.zoom < 1.35)
					{
						FlxG.camera.zoom += 0.0075;
						camHUD.zoom += 0.015;
					}
					if(!(curBeat == 1088)) //To prevent alert flashing when I don't want it too.
						qt_tv01.animation.play("alert");
				}
		}
		else if(SONG.song.toLowerCase() == "careless") //Mid-song events for Careless. Mainly for the TV though.
		{  
			if(curBeat == 190 || curBeat == 191 || curBeat == 224){
				qt_tv01.animation.play("eye");
			}
			else if(curBeat >= 192 && curStep <= 895){
				qt_tv01.animation.play("alert");
			}
			else if(curBeat == 225){
				qt_tv01.animation.play("idle");
			}
				
		}
		else if(SONG.song.toLowerCase() == "cessation") //Mid-song events for cessation. Mainly for the TV though.
		{  
			qt_tv01.animation.play("heart");
		}


		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0)
		{
			gf.dance();
		}

		if (!boyfriend.animation.curAnim.name.startsWith("sing") && !bfDodging)
		{
			boyfriend.dance();
			//boyfriend.playAnim('idle');
		}
		//Copy and pasted code for BF to see if it would work for Dad to animate Dad during their section (previously, they just froze) -Haz
		//Seems to have fixed a lot of problems with idle animations with Dad. Success! -A happy Haz
		if(SONG.notes[Math.floor(curStep / 16)] != null) //Added extra check here so song doesn't crash on careless.
		{
			if (!(SONG.notes[Math.floor(curStep / 16)].mustHitSection) && !dad.animation.curAnim.name.startsWith("sing"))
			{
				/*if(!qtIsBlueScreened && !qtCarelessFin)
					if(SONG.song.toLowerCase() == "cessation"){
						if((curStep >= 640 && curStep <= 794) || (curStep >= 1040 && curStep <= 1199))
						{
							dad.dance(true);
						}else{
							dad.dance();
						}
					}
					else
						dad.dance();
			}
		}*/

		//Same as above, but for 404 variants.
		if(qtIsBlueScreened)
		{
			if (!boyfriend404.animation.curAnim.name.startsWith("sing") && !bfDodging)
			{
				boyfriend404.playAnim('idle');
			}

			//Termination KB animates every 2 curstep instead of 4 (aka, every half beat, not every beat!)
			if(curStage!="nightmare"){ //No idea why this line causes a crash on REDACTED so erm... fuck you.
				if(!(SONG.song.toLowerCase() == "termination" || SONG.song.toLowerCase() == "extermination")){
					if (SONG.notes[Math.floor(curStep / 16)].mustHitSection && !dad404.animation.curAnim.name.startsWith("sing"))
					{
						dad404.dance();
					}
				}
			}
		}
		else if (curSong.toLowerCase() == 'expurgation'){
			if(qtIsBlueScreened)
				{
					//Termination KB animates every 2 curstep instead of 4 (aka, every half beat, not every beat!)
					if (SONG.notes[Math.floor(curStep / 16)].mustHitSection && !dad404.animation.curAnim.name.startsWith("sing") && curStep % 2 == 0)
					{
						dad404.dance();
					}
				}
		}

		


		if(FlxG.save.data.shadersOn)
		{
			if (curBeat > 0 && !shadersLoaded)
			{
				shadersLoaded = true;

				filters.push(Shaders.chromaticAberration);
			
				camfilters.push(Shaders.chromaticAberration);

				filters.push(Shaders.vignette);

			}
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			if (SONG.notes[Math.floor(curStep / 16)].changeDadCharacter)
			{
				changeDadCharacter(SONG.notes[Math.floor(curStep / 16)].changeDadCharacterChar);
				FlxG.log.add('CHANGED DAD!');
			}
			if (SONG.notes[Math.floor(curStep / 16)].changeBFCharacter)
			{
				changeBFCharacter(SONG.notes[Math.floor(curStep / 16)].changeBFCharacterChar);
				FlxG.log.add('CHANGED BF!');
			}
			if (SONG.notes[Math.floor(curStep / 16)].chromaticAberrationsShader)
			{
				chromOn = true;
				FlxG.log.add('Chromatic Aberrations enabled');
			}
			else
			{
				chromOn = false;
				FlxG.log.add('Chromatic Aberrations disabled');
			}
			if (SONG.notes[Math.floor(curStep / 16)].vignetteShader)
			{
				vignetteOn = true;
				FlxG.log.add('vignette enabled');
				vignetteRadius = SONG.notes[Math.floor(curStep / 16)].vignetteShaderRadius;
			}
			else
			{
				vignetteOn = false;
				FlxG.log.add('vignette disabled');
			}
			if(SONG.notes[Math.floor(curStep / 16)].changeCameraBeat)
			{
				cameraBeatZoom = 0.015 * SONG.notes[Math.floor(curStep / 16)].cameraBeatZoom;
				cameraBeatSpeed = SONG.notes[Math.floor(curStep / 16)].cameraBeatSpeed;
			}
			else
			{
				cameraBeatZoom = 0.015;
				cameraBeatSpeed = 4;
			}
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			if (SONG.notes[Math.floor(curStep / 16)].mustHitSection)
				dad.dance();
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		/* HARDCODING FOR MILF ZOOMS!
		if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
		{
			FlxG.camera.zoom += cameraBeatZoom;
			camHUD.zoom += cameraBeatZoom * 2;
		}

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % cameraBeatSpeed == 0)
		{
			FlxG.camera.zoom += cameraBeatZoom;
			camHUD.zoom += cameraBeatZoom * 2;
		}

		if(curBeat % cameraBeatSpeed == 0)
		{
			iconP1.angle -= 40;
			iconP2.angle += 40;
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
                iconP2.setGraphicSize(Std.int(iconP2.width + 30));
                iconP1.updateHitbox();
                iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0)
		{
			gf.dance();
		}

		if (!boyfriend.animation.curAnim.name.startsWith("sing") && curBeat % 2 == 0)
		{
			boyfriend.dance();

		}*/


		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
		{
			boyfriend.playAnim('hey', true);
		}

		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}

		switch (curStage)
		{
			case 'school':
				bgGirls.dance();

			case 'mall':
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

			case 'limo':
				grpLimoDancers.forEach(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			/*case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					phillyCityLights.forEach(function(light:FlxSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1);

					phillyCityLights.members[curLight].visible = true;

					phillyCityLights.members[curLight].alpha = 1;
					FlxTween.tween(phillyCityLights.members[curLight], {alpha: 0}, Conductor.crochet / 1000 * 4, {ease: FlxEase.linear});*/
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
		if((FlxG.random.bool(7) && !boyfriend.animation.curAnim.name.startsWith('sing') && curBeat > spinMicBeat + spinMicOffset) && boyfriend.animation.getByName("spinMic") != null)
		{
			boyfriendSpinMic();
		}
	}

	var curLight:Int = 0;
}
}
