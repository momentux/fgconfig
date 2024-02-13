import '../utils/service_handler.dart';

class FGArgs {
  final bool? autoPilot;
  final String? targetOption;
  final String? typeOfTarget;
  final String? targetSubOption;
  final String? airport;
  final double? latitudeValue;
  final double? longitudeValue;
  final int? altitudeValue;
  final int? headingValue;
  final Map<Service, bool>? serviceStates;
  final String? filename;
  final String? state;
  final bool? inAir;

  FGArgs(
      {this.autoPilot,
      this.targetOption,
      this.typeOfTarget,
      this.targetSubOption,
      this.airport,
      this.latitudeValue,
      this.longitudeValue,
      this.altitudeValue,
      this.headingValue,
      this.serviceStates,
      this.filename,
      this.state,
      this.inAir});

  List<String> getArgString() {
    List<String> fgArgs = baseArgs();

    if (inAir!) {
      fgArgs.addAll([
        '--lat=$latitudeValue',
        '--lon=$longitudeValue',
        '--altitude=$altitudeValue',
        '--in-air',
        '--vc=600',
        '--state=$state',
      ]);
      if (autoPilot!) {
        fgArgs.addAll([
          '--heading=$headingValue',
          '--prop:/instrumentation/heading-indicator/heading-bug-deg=$headingValue',
          '--prop:/f16/fcs/switch-pitch-block20=1',
          '--prop:/f16/fcs/switch-roll-block20=0',
        ]);
      }
    } else {
      fgArgs.addAll(['--airport=$airport', '--runway=active']);
    }

    if (targetOption == "FG AI Scenario") {
      fgArgs.add('--ai-scenario=$filename');
      if (typeOfTarget == "Air Target" ||
          typeOfTarget == "Sea Target" ||
          typeOfTarget == "Ground Target") {
        fgArgs.add(
            '--generic=socket,out,10,134.32.255.255,5505,udp,${typeOfTarget!.split(' ')[0].toUpperCase()}');
      }
    } else if (targetSubOption == "Replay Recorded Data") {
      fgArgs.add('--prop:/sim/ai/scenario=$filename');
    }

    return fgArgs;
  }

  List<String> baseArgs() {
    return """
### mac
--download-dir=/Users/rverma2/atlassian/fgconfig/Downloads
--fg-scenery=/Users/rverma2/atlassian/fgconfig/Scenery
--fg-aircraft=/Users/rverma2/atlassian/fgconfig/Aircrafts
--aircraft-dir=/Users/rverma2/atlassian/fgconfig/Aircrafts/f16
--flight-plan=/Users/rverma2/atlassian/fgconfig/config/modified_vobg.xml

### Aircraft specifics
--aircraft=f16-block-60

### System
--enable-fullscreen
--enable-freeze
--disable-terrasync
--disable-distance-attenuation
--disable-real-weather-fetch
--disable-ai-traffic
--disable-random-objects
--disable-clouds
--disable-clouds3d
--disable-specular-highlight
--fog-fastest
--visibility=5000
--timeofday=noon
--disable-rembrandt
--prop:/nasal/local_weather/enabled=false
--launcher=0
--json-report

### Rendering
--fov=65
--prop:/sim/rendering/multithreading-mode=CullThreadPerCameraDrawThreadPerContext
--prop:/sim/rendering/random-vegetation=0
--prop:/sim/rendering/random-buildings=0
--prop:/sim/rendering/shaders/skydome=0
--prop:/sim/rendering/particles=0
--prop:/sim/rendering/multi-samples=1
--prop:/sim/rendering/texture-cache/cache-enabled=1
--prop:/sim/rendering/draw-mask/models=0
--prop:/sim/rendering/draw-mask/clouds=0
--prop:/sim/rendering/draw-mask/terrain=0

### AI and Traffic
--enable-ai-models
--prop:/sim/traffic-manager/enabled=0

### Network and logging
--model-hz=500
--telnet=5401
--httpd=8181
--max-fps=120
"""
        .split('\n')
        .where((line) => line.isNotEmpty && !line.startsWith('#'))
        .toList();
  }
}

// fgArgs.add('--generic=file,out,10,C:\\Users\\scl\\Flightgear\\airtarget.csv,AIRCSV');
