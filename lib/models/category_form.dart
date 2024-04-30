class CategoryInfo {
  static const categoryTitles = {
    Lining: '안감',
    Elasticity: '신축성',
    Transparency: '비침',
    ClothingTexture: '촉감',
    Fit: '핏감',
    Thickness: '두께감',
    Season: '계절감',
  };

  static final liningLabels = {
    Lining.yes: '있음',
    Lining.no: '없음',
    Lining.fleece: '기모',
  };

  static final elasticityLabels = {
    Elasticity.good: '좋음',
    Elasticity.normal: '보통',
    Elasticity.none: '없음',
  };

  static final transparencyLabels = {
    Transparency.none: '없음',
    Transparency.slight: '약간',
    Transparency.yes: '있음',
  };

  static final textureLabels = {
    ClothingTexture.soft: '부드러움',
    ClothingTexture.normal: '보통',
    ClothingTexture.rough: '까칠함',
  };

  static final fitLabels = {
    Fit.tight: '타이트',
    Fit.regular: '정사이즈',
    Fit.loose: '루즈',
  };

  static final thicknessLabels = {
    Thickness.thick: '도톰',
    Thickness.normal: '보통',
    Thickness.thin: '얇음',
  };

  static final seasonLabels = {
    Season.springFall: '봄가을',
    Season.summer: '여름',
    Season.winter: '겨울',
  };

  static final categoryForms = {
    '맨투맨': ['총장', '어깨단면', '가슴단면', '소매길이', '소매단면', '암홀단면', '밑단단면'],
    '반팔티': ['총장', '어깨단면', '가슴단면', '소매길이', '소매단면', '암홀단면', '밑단단면'],
    '후드티': ['총장', '어깨단면', '가슴단면', '소매길이', '소매단면', '암홀단면', '밑단단면'],
    '니트': ['총장', '어깨단면', '가슴단면', '소매길이', '소매단면', '암홀단면', '밑단단면'],
    '나시': ['총장', '어깨단면', '가슴단면', '암홀단면', '밑단단면'],
    '셔츠': ['총장', '어깨단면', '가슴단면', '허리단면', '소매길이', '소매단면', '암홀단면', '밑단단면'],
    '블라우스': ['총장', '어깨단면', '가슴단면', '허리단면', '소매길이', '소매단면', '암홀단면', '밑단단면'],
    '코트': ['총장', '어깨단면', '가슴단면', '허리단면', '소매길이', '소매단면', '암홀단면', '밑단단면'],
    '바지': ['총장', '허리', '힙단면', '밑위길이', '허벅지단면', '밑단단면'],
    '롱 치마': ['총장', '허리', '힙단면', '밑단단면'],
    '숏 치마': ['총장', '허리', '힙단면', '밑단단면'],
    '스커트': ['총장', '허리', '힙단면', '밑단단면'],
    '롱 원피스': ['총장', '어깨단면', '가슴단면', '허리단면', '소매길이', '소매단면', '암홀단면', '밑단단면'],
    '숏 원피스': ['총장', '어깨단면', '가슴단면', '허리단면', '소매길이', '소매단면', '암홀단면', '밑단단면'],
    '점프수트': ['총장', '어깨단면', '가슴단면', '허리단면', '소매길이', '소매단면', '암홀단면', '밑단단면'],
  };
}

enum Lining { yes, no, fleece }
enum Elasticity { good, normal, none }
enum Transparency { none, slight, yes }
enum ClothingTexture { soft, normal, rough }
enum Fit { tight, regular, loose }
enum Thickness { thick, normal, thin }
enum Season { springFall, summer, winter }

class TopSizeInfo {
  double? totalLength;
  double? shoulderWidth;
  double? chestWidth;
  double? sleeveLength;
  double? sleeveWidth;
  double? armholeWidth;
  double? hemWidth;

  TopSizeInfo({
    this.totalLength,
    this.shoulderWidth,
    this.chestWidth,
    this.sleeveLength,
    this.sleeveWidth,
    this.armholeWidth,
    this.hemWidth,
  });
}

class TopInfo {
  TopSizeInfo? topSizeInfo;
  Lining? lining;
  Elasticity? elasticity;
  Transparency? transparency;
  ClothingTexture? texture;
  Fit? fit;
  Thickness? thickness;
  Season? season;

  TopInfo({
    this.topSizeInfo,
    this.lining,
    this.elasticity,
    this.transparency,
    this.texture,
    this.fit,
    this.thickness,
    this.season,
  });
}

class BottomSizeInfo {
  double? totalLength;
  double? waistWidth;
  double? hipWidth;
  double? crotchLength;
  double? thighWidth;
  double? hemWidth;

  BottomSizeInfo({
    this.totalLength,
    this.waistWidth,
    this.hipWidth,
    this.crotchLength,
    this.thighWidth,
    this.hemWidth,
  });
}

class BottomInfo {
  BottomSizeInfo? bottomSizeInfo;
  Lining? lining;
  Elasticity? elasticity;
  Transparency? transparency;
  ClothingTexture? texture;
  Fit? fit;
  Thickness? thickness;
  Season? season;

  BottomInfo({
    this.bottomSizeInfo,
    this.lining,
    this.elasticity,
    this.transparency,
    this.texture,
    this.fit,
    this.thickness,
    this.season,
  });
}

class DressSizeInfo {
  double? totalLength;
  double? shoulderWidth;
  double? chestWidth;
  double? waistWidth;
  double? sleeveLength;
  double? sleeveWidth;
  double? armholeWidth;
  double? hemWidth;

  DressSizeInfo({
    this.totalLength,
    this.shoulderWidth,
    this.chestWidth,
    this.waistWidth,
    this.sleeveLength,
    this.sleeveWidth,
    this.armholeWidth,
    this.hemWidth,
  });
}

class DressInfo {
  DressSizeInfo? dressSizeInfo;
  Lining? lining;
  Elasticity? elasticity;
  Transparency? transparency;
  ClothingTexture? texture;
  Fit? fit;
  Thickness? thickness;
  Season? season;

  DressInfo({
    this.dressSizeInfo,
    this.lining,
    this.elasticity,
    this.transparency,
    this.texture,
    this.fit,
    this.thickness,
    this.season,
  });
}