class BuildVersion {
  final String versionName;
  final int versionCode;

  BuildVersion(this.versionName, this.versionCode);

  @override
  String toString() =>
      'BuildVersion(versionName: $versionName, versionCode: $versionCode)';
}

/// Compare deux versions de build :
/// 1. On compare versionCode (int) — celui qui a le plus grand code gagne.
/// 2. Si versionCode identiques, on compare versionName (string) lexicographiquement.
BuildVersion pickHigherBuild(BuildVersion a, BuildVersion b) {
 String v1=a.versionName.replaceAll(" ", "");
 v1=v1.replaceAll('.', "");

 

 String v2=b.versionName.replaceAll(" ", "");
 v2=v2.replaceAll('.', "");
print(int.parse(v1));print(int.parse(v2));

  if(int.parse(v1)>int.parse(v2)){

    return a;
  }
    if(!(int.parse(v1)>int.parse(v2)))return b;

    return a.versionCode >b.versionCode?a:b ;




  


}
