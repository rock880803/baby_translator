enum MBTIType {
  INTJ, INTP, ENTJ, ENTP,
  INFJ, INFP, ENFJ, ENFP,
  ISTJ, ISFJ, ESTJ, ESFJ,
  ISTP, ISFP, ESTP, ESFP
}

extension MBTITypeExtension on MBTIType {
  String get displayName => name;

  String get description {
    switch (this) {
      case MBTIType.INTJ:
        return '建築師 - 富有想像力和戰略性的思想家';
      case MBTIType.INTP:
        return '邏輯學家 - 富有創造力的發明家';
      case MBTIType.ENTJ:
        return '指揮官 - 大膽、富有想像力的領導者';
      case MBTIType.ENTP:
        return '辯論家 - 聰明好奇的思想家';
      case MBTIType.INFJ:
        return '提倡者 - 安靜神秘的理想主義者';
      case MBTIType.INFP:
        return '調停者 - 詩意善良的利他主義者';
      case MBTIType.ENFJ:
        return '主人公 - 魅力四射的領導者';
      case MBTIType.ENFP:
        return '競選者 - 熱情洋溢的自由精神';
      case MBTIType.ISTJ:
        return '物流師 - 實際可靠的事實管理者';
      case MBTIType.ISFJ:
        return '守衛者 - 非常專注的守護者';
      case MBTIType.ESTJ:
        return '總經理 - 出色的管理者';
      case MBTIType.ESFJ:
        return '執政官 - 極有同情心的協調者';
      case MBTIType.ISTP:
        return '鑒賞家 - 大膽實際的實驗者';
      case MBTIType.ISFP:
        return '探險家 - 靈活迷人的藝術家';
      case MBTIType.ESTP:
        return '企業家 - 精明大膽的實幹家';
      case MBTIType.ESFP:
        return '表演者 - 自發的娛樂者';
    }
  }
}
