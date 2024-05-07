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
    // '아우터': ['가디건', '자켓/코트(숏)', '자켓/코트(롱)', '점퍼', '베스트(패딩조끼)'],
    '가디건': ['총장', '어깨단면', '가슴단면', '소매길이', '소매단면', '암홀단면', '밑단단면'],
    '자켓/코트(숏)': ['총장', '어깨단면', '가슴단면', '소매길이', '소매단면', '암홀단면', '밑단단면'],
    '자켓/코트(롱)': ['총장', '어깨단면', '가슴단면', '소매길이', '소매단면', '암홀단면', '밑단단면'],
    '점퍼': ['총장', '어깨단면', '가슴단면', '소매길이', '소매단면', '암홀단면', '밑단단면'],
    '베스트(패딩조끼)': ['총장', '어깨단면', '가슴단면', '암홀단면', '밑단단면'],

    // '상의': ['티셔츠(긴소매)', '티셔츠(반소매)', '티셔츠(목폴라)', '민소매(조끼)', '블라우스(셔츠)'],
    '티셔츠(긴소매)': ['총장', '어깨단면', '가슴단면', '소매길이', '소매단면', '암홀단면', '밑단단면'],
    '티셔츠(반소매)': ['총장', '어깨단면', '가슴단면', '소매길이', '소매단면', '암홀단면', '밑단단면'],
    '티셔츠(목폴라)': ['총장', '어깨단면', '가슴단면', '소매길이', '소매단면', '암홀단면', '밑단단면', '목높이'],
    '민소매(조끼)': ['총장', '어깨단면', '가슴단면', '암홀단면', '밑단단면'],
    '블라우스(셔츠)': ['총장', '어깨단면', '가슴단면', '허리단면', '소매길이', '소매단면', '암홀단면', '밑단단면'],

    // '원피스': ['긴팔원피스', '반팔원피스', '민소매원피스', '목폴라원피스'],
    '긴팔원피스': ['총장', '어깨단면', '가슴단면', '허리단면', '소매길이', '소매단면', '암홀단면', '밑단단면'],
    '반팔원피스': ['총장', '어깨단면', '가슴단면', '허리단면', '소매길이', '소매단면', '암홀단면', '밑단단면'],
    '민소매원피스': ['총장', '어깨단면', '가슴단면', '허리단면', '암홀단면', '밑단단면'],
    '목폴라원피스': ['총장', '어깨단면', '가슴단면', '허리단면', '소매길이', '소매단면', '암홀단면', '밑단단면', '목높이'],

    // '패션소품': ['가방', '신발', '기타'],
    '가방': ['높이', '넓이', '폭', '끈길이'],
    '신발': ['굽높이', '발볼'],

    // '팬츠': ['긴바지', '반바지', '점프수트'],
    '긴바지': ['총장', '허리', '힙단면', '밑위길이', '허벅지단면', '밑단단면'],
    '반바지': ['총장', '허리', '힙단면', '밑위길이', '허벅지단면', '밑단단면'],
    '점프수트': ['총장', '허리단면', '힙단면', '밑위길이', '허벅지단면', '밑단단면', '가슴단면'],

    // '스커트': ['미니스커트', '롱스커트']
    '미니스커트': ['총장', '허리', '힙단면', '밑단단면'],
    '롱스커트': ['총장', '허리', '힙단면', '밑단단면'],
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