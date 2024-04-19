enum Lining { yes, no, fleece }
enum Elasticity { good, normal, none }
enum Transparency { none, slight, yes }
enum ClothingTexture { soft, normal, rough }
enum Fit { tight, regular, loose }
enum Thickness { thick, normal, thin }
enum Season { springFall, summer, winter }

Map<Lining, String> liningLabels = {
  Lining.yes: '있음',
  Lining.no: '없음',
  Lining.fleece: '기모',
};

Map<Elasticity, String> elasticityLabels = {
  Elasticity.good: '좋음',
  Elasticity.normal: '보통',
  Elasticity.none: '없음',
};

Map<Transparency, String> transparencyLabels = {
  Transparency.none: '없음',
  Transparency.slight: '약간',
  Transparency.yes: '있음',
};

Map<ClothingTexture, String> textureLabels = {
  ClothingTexture.soft: '부드러움',
  ClothingTexture.normal: '보통',
  ClothingTexture.rough: '까칠함',
};

Map<Fit, String> fitLabels = {
  Fit.tight: '타이트',
  Fit.regular: '정사이즈',
  Fit.loose: '루즈',
};

Map<Thickness, String> thicknessLabels = {
  Thickness.thick: '도톰',
  Thickness.normal: '보통',
  Thickness.thin: '얇음',
};

Map<Season, String> seasonLabels = {
  Season.springFall: '봄가을',
  Season.summer: '여름',
  Season.winter: '겨울',
};

Map<String, List<String>> categoryForms = {
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