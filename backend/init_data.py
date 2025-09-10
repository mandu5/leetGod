import asyncio
import os
import sys
from datetime import datetime

# 프로젝트 루트를 Python 경로에 추가
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from models.database import init_db, SessionLocal
from models.user import User, UserCreate
from models.question import QuestionBank, QuestionCreate
from models.voucher import Voucher, UserVoucher, PaymentHistory, PaymentMethod
from services.auth_service import AuthService
from services.question_service import QuestionService
import os
from dotenv import load_dotenv

load_dotenv()

# 샘플 문제 데이터 (리트 시험 문제 포함)
SAMPLE_QUESTIONS = [
    # 언어이해 문제들
    {
        "subject": "언어이해",
        "unit": "인식론",
        "difficulty": 4,
        "points": 4,
        "question_type": "객관식",
        "content": "현상적 보수주의(Phenomenal Conservatism)는 인식론의 한 흐름으로, 어떤 명제 P가 어떤 사람 S에게 그렇게 보이는(seems) 경우, 다른 반대 증거가 없다면 S는 P를 믿을 만한 잠정적 정당성을 가진다는 원칙을 핵심으로 한다. 여기서 '그렇게 보임'은 감각적 경험뿐만 아니라, 직관, 기억, 내성 등 이성적이고 내면적인 '지적 현상'까지 포괄하는 넓은 개념이다. 예를 들어, 눈앞에 붉은 사과가 있는 것처럼 보일 때 우리는 '사과가 붉다'고 믿을 정당성을 가지며, 복잡한 수학 증명을 검토한 후 그 결론이 참인 것처럼 보일 때 역시 그 결론을 믿을 정당성을 갖는다. 이 이론의 강점은 모든 지식의 근원을 소수의 기초 명제(예: 감각 경험)로 환원하려는 토대주의의 난점을 피하면서도, 우리의 상식적인 믿음 형성 과정을 잘 설명한다는 데 있다. 즉, 우리는 일반적으로 어떤 믿음을 갖기 위해 그것을 지지하는 별도의 긍정적 근거를 먼저 찾기보다는, 일단 그렇게 보이는 바를 받아들이고 반대 증거가 나타날 때에만 믿음을 수정하는 방식으로 사유하기 때문이다.\n\n윗글의 내용과 일치하는 것은?",
        "options": [
            "현상적 보수주의는 감각적 경험만이 믿음을 정당화하는 유일한 원천이라고 본다.",
            "'그렇게 보임'은 반대 증거가 나타나면 더 이상 믿음의 정당성을 제공하지 못한다.",
            "토대주의는 현상적 보수주의와 달리 지식의 근원을 다양한 지적 현상에서 찾는다.",
            "어떤 명제가 참인 것처럼 보이는 경우, 반대 증거의 유무와 상관없이 그 믿음은 정당화된다.",
            "현상적 보수주의에 따르면, 어떤 믿음을 갖기 위해서는 그것을 지지하는 별도의 긍정적 근거가 반드시 선행되어야 한다."
        ],
        "correct_answer": "'그렇게 보임'은 반대 증거가 나타나면 더 이상 믿음의 정당성을 제공하지 못한다.",
        "explanation": "② 정답. 본문에서 현상적 보수주의는 '다른 반대 증거가 없다면'이라는 조건을 통해 '그렇게 보임'이 제공하는 정당성이 '잠정적'임을 명시하고 있다. 따라서 반대 증거가 나타나면 기존의 정당성은 철회되거나 수정될 수 있다.",
        "tags": ["언어이해", "인식론", "현상적 보수주의"]
    },
    {
        "subject": "언어이해",
        "unit": "신경과학",
        "difficulty": 3,
        "points": 4,
        "question_type": "객관식",
        "content": "신경과학에서 시냅스 가소성(synaptic plasticity)은 학습과 기억의 핵심적인 세포 메커니즘으로 여겨진다. 시냅스 가소성이란 신경세포(뉴런) 간의 연결 부위인 시냅스의 신호 전달 효율이 신경 활동에 따라 지속적으로 변하는 현상을 말한다. 대표적인 형태로는 장기 강화 작용(LTP)과 장기 약화 작용(LTD)이 있다. LTP는 두 뉴런 사이의 시냅스 연결이 반복적이고 강한 자극으로 인해 강화되는 현상으로, 특정 기억이 장기기억으로 저장되는 과정에 관여하는 것으로 생각된다. 반대로 LTD는 약한 자극이 지속될 때 시냅스 연결이 약화되는 현상으로, 불필요한 기억을 지우거나 새로운 학습을 위해 기존의 신경 회로를 재조정하는 역할을 한다.\n\n윗글의 내용과 일치하지 않는 것은?",
        "options": [
            "시냅스 가소성은 학습과 기억의 세포 수준 메커니즘이다.",
            "LTP와 LTD는 모두 시냅스후 뉴런의 칼슘 이온 농도 변화와 관련이 있다.",
            "시냅스 연결 강도는 신경 활동에 따라 강화되거나 약화될 수 있다.",
            "장기 약화 작용(LTD)은 오래된 기억을 공고히 하는 데 필수적인 과정이다.",
            "강한 자극은 LTP를 유도하는 효소를 활성화시킨다."
        ],
        "correct_answer": "장기 약화 작용(LTD)은 오래된 기억을 공고히 하는 데 필수적인 과정이다.",
        "explanation": "④ 정답. 본문은 LTD가 '불필요한 기억을 지우거나' 기존 회로를 재조정하는 역할을 한다고 설명한다. 이는 기억을 공고히 하는 것과는 반대되는 기능이다.",
        "tags": ["언어이해", "신경과학", "시냅스 가소성"]
    },
    {
        "subject": "언어이해",
        "unit": "법학",
        "difficulty": 4,
        "points": 4,
        "question_type": "객관식",
        "content": "법의 해석에서 '목적론적 해석'은 법률 조항의 문자적 의미에만 얽매이지 않고, 그 법률이 제정된 목적, 즉 입법 취지를 고려하여 그 의미를 파악하는 방법이다. 이는 법률 문언이 모호하거나, 사회 변화로 인해 문자적 의미를 그대로 적용하는 것이 불합리한 결과를 낳는 경우에 특히 중요한 역할을 한다. 목적론적 해석은 다시 '주관적 목적론'과 '객관적 목적론'으로 나뉜다. 주관적 목적론은 법률 제정 당시 입법자의 주관적 의사를 탐구하여 그것을 해석의 기준으로 삼는다. 반면, 객관적 목적론은 입법자의 주관적 의사에서 벗어나, 현재의 법질서 전체의 맥락 속에서 그 법률 조항이 가져야 할 객관적인 의미와 기능을 탐구한다.\n\n윗글에 대한 이해로 적절하지 않은 것은?",
        "options": [
            "목적론적 해석은 법률 문언의 의미가 불분명할 때 유용하게 사용될 수 있다.",
            "주관적 목적론은 법률 제정 당시의 역사적 자료를 중요한 해석의 근거로 삼는다.",
            "객관적 목적론은 법률의 의미가 시대적 상황에 따라 변할 수 있다고 본다.",
            "주관적 목적론은 객관적 목적론에 비해 법적 안정성을 더 중시하는 경향이 있다.",
            "객관적 목적론은 입법자의 의도를 파악하는 것을 법 해석의 최종 목표로 삼는다."
        ],
        "correct_answer": "객관적 목적론은 입법자의 의도를 파악하는 것을 법 해석의 최종 목표로 삼는다.",
        "explanation": "⑤ 정답. 본문은 객관적 목적론이 '입법자의 주관적 의사에서 벗어나' 현재의 법질서 전체의 맥락에서 법률의 객관적 의미를 탐구한다고 설명한다.",
        "tags": ["언어이해", "법학", "법의 해석"]
    },
    # 추리논증 문제들
    {
        "subject": "추리논증",
        "unit": "논리학",
        "difficulty": 3,
        "points": 4,
        "question_type": "객관식",
        "content": "다음 중 형식적으로 타당한 논증은?",
        "options": [
            "모든 인간은 죽는다. 소크라테스는 죽는다. 따라서 소크라테스는 인간이다.",
            "비가 오면 땅이 젖는다. 땅이 젖었다. 따라서 비가 왔다.",
            "어떤 철학자는 논리학자이다. 모든 논리학자는 이성적이다. 따라서 어떤 철학자는 이성적이다.",
            "내가 로또에 당첨된다면, 나는 부자가 될 것이다. 나는 부자가 되지 못했다. 따라서 나는 로또에 당첨되지 못할 것이다.",
            "용감한 사람은 두려움을 느끼지 않는다. 철수는 두려움을 느낀다. 따라서 철수는 용감하지 않다."
        ],
        "correct_answer": "어떤 철학자는 논리학자이다. 모든 논리학자는 이성적이다. 따라서 어떤 철학자는 이성적이다.",
        "explanation": "③ 정답. 이는 타당한 삼단논법(특칭긍정+전칭긍정)의 형식을 따른다. 철학자이면서 논리학자인 사람이 존재하고, 모든 논리학자는 이성적이므로, 철학자이면서 이성적인 사람이 반드시 존재한다.",
        "tags": ["추리논증", "논리학", "삼단논법"]
    },
    {
        "subject": "추리논증",
        "unit": "경제학",
        "difficulty": 4,
        "points": 4,
        "question_type": "객관식",
        "content": "다음 주장을 가장 강력하게 뒷받침하는 것은?\n\n'최저임금의 인상은 저임금 근로자의 소득을 증대시키기보다는 오히려 고용을 감소시켜 그들의 경제 상황을 악화시킬 수 있다.'",
        "options": [
            "최저임금 인상 후 편의점 아르바이트생의 월평균 소득이 증가했다.",
            "최저임금을 인상한 A국과 동결한 B국의 실업률 변화가 비슷했다.",
            "최저임금이 대폭 인상된 해에, 저임금 일자리의 대표격인 외식업계의 신규 고용이 전년 대비 30% 감소했다.",
            "최저임금위원회는 내년도 최저임금을 5% 인상하기로 결정했다.",
            "한 경제 연구소는 최저임금 인상이 소비를 촉진시켜 경제 성장에 기여한다고 발표했다."
        ],
        "correct_answer": "최저임금이 대폭 인상된 해에, 저임금 일자리의 대표격인 외식업계의 신규 고용이 전년 대비 30% 감소했다.",
        "explanation": "③ 정답. 주장의 핵심은 최저임금 인상이 '고용 감소'를 유발한다는 것이다. 최저임금이 대폭 인상된 시점과 저임금 일자리가 많은 외식업계의 신규 고용이 급감한 시점이 일치한다는 것은 주장과 부합하는 강력한 상관관계를 보여주므로 주장을 뒷받침한다.",
        "tags": ["추리논증", "경제학", "최저임금"]
    },
    {
        "subject": "추리논증",
        "unit": "논리게임",
        "difficulty": 4,
        "points": 4,
        "question_type": "객관식",
        "content": "A, B, C, D 네 사람이 있고, 이들 중 한 명은 범인이다. 네 사람은 다음과 같이 진술했으며, 네 사람의 진술 중 단 하나의 진술만이 참이다.\n\nA: '나는 범인이 아니다.'\nB: 'C는 범인이다.'\nC: 'D가 범인이다.'\nD: '나는 범인이 아니다.'\n\n범인은 누구인가?",
        "options": [
            "A",
            "B", 
            "C",
            "D",
            "알 수 없다."
        ],
        "correct_answer": "A",
        "explanation": "① 정답. 각 사람이 범인이라고 가정하고 진술의 참/거짓을 따져본다. A가 범인이라면: A의 진술은 거짓, B의 진술은 거짓, C의 진술은 거짓, D의 진술은 참. 참인 진술이 하나이므로 조건을 만족한다.",
        "tags": ["추리논증", "논리게임", "진술 분석"]
    },
    # 기존 법학 문제들
    {
        "subject": "민법",
        "unit": "민법총칙",
        "difficulty": 2,
        "points": 3,
        "question_type": "객관식",
        "content": "민법 제1조에서 규정하고 있는 신의성실의 원칙에 대한 설명으로 옳은 것은?",
        "options": ["계약 체결 시에만 적용된다", "모든 권리행사와 의무이행에 적용된다", "재산권에만 적용된다", "법인에게는 적용되지 않는다"],
        "correct_answer": "모든 권리행사와 의무이행에 적용된다",
        "explanation": "신의성실의 원칙은 모든 권리행사와 의무이행에 있어서 신의에 좇아 성실히 하여야 한다는 원칙입니다.",
        "tags": ["민법총칙", "신의성실의 원칙"]
    },
    {
        "subject": "민법",
        "unit": "물권법",
        "difficulty": 3,
        "points": 4,
        "question_type": "주관식",
        "content": "소유권의 내용에 해당하는 권능 3가지를 쓰시오.",
        "options": None,
        "correct_answer": "사용권능, 수익권능, 처분권능",
        "explanation": "소유권은 사용권능(사용할 권리), 수익권능(수익을 얻을 권리), 처분권능(처분할 권리)으로 구성됩니다.",
        "tags": ["물권법", "소유권"]
    },
    {
        "subject": "민법",
        "unit": "채권법",
        "difficulty": 3,
        "points": 4,
        "question_type": "객관식",
        "content": "채무불이행에 대한 설명으로 틀린 것은?",
        "options": ["이행지체", "이행불능", "불완전이행", "이행거절"],
        "correct_answer": "이행거절",
        "explanation": "채무불이행의 유형은 이행지체, 이행불능, 불완전이행 3가지입니다. 이행거절은 채무불이행의 독립적 유형이 아닙니다.",
        "tags": ["채권법", "채무불이행"]
    },
    {
        "subject": "헌법",
        "unit": "기본권",
        "difficulty": 4,
        "points": 5,
        "question_type": "주관식",
        "content": "헌법 제37조 제2항에서 규정하고 있는 기본권 제한의 요건을 쓰시오.",
        "options": None,
        "correct_answer": "국가안전보장, 질서유지, 공공복리",
        "explanation": "헌법 제37조 제2항에 따르면 기본권은 국가안전보장, 질서유지, 공공복리를 위하여 필요한 경우에 한하여 법률로써 제한할 수 있습니다.",
        "tags": ["헌법", "기본권 제한"]
    },
    {
        "subject": "형법",
        "unit": "형법총론",
        "difficulty": 2,
        "points": 3,
        "question_type": "객관식",
        "content": "범죄의 성립요건이 아닌 것은?",
        "options": ["구성요건해당성", "위법성", "책임", "처벌조건"],
        "correct_answer": "처벌조건",
        "explanation": "범죄의 성립요건은 구성요건해당성, 위법성, 책임 3가지입니다. 처벌조건은 범죄성립요건이 아닙니다.",
        "tags": ["형법총론", "범죄의 성립요건"]
    },
    {
        "subject": "상법",
        "unit": "회사법",
        "difficulty": 1,
        "points": 3,
        "question_type": "객관식",
        "content": "주식회사의 기관이 아닌 것은?",
        "options": ["주주총회", "이사회", "감사", "사원총회"],
        "correct_answer": "사원총회",
        "explanation": "사원총회는 합명회사, 합자회사의 기관이고, 주식회사의 기관은 주주총회, 이사회, 감사입니다.",
        "tags": ["회사법", "주식회사 기관"]
    },
    {
        "subject": "헌법",
        "unit": "통치구조",
        "difficulty": 4,
        "points": 5,
        "question_type": "주관식",
        "content": "국정감사권과 국정조사권의 차이점을 설명하시오.",
        "options": None,
        "correct_answer": "국정감사권은 정기적, 포괄적이고 국정조사권은 특정사안에 대해 수시로 행사",
        "explanation": "국정감사권은 매년 정기적으로 행정부 전반에 대해 포괄적으로 행사되지만, 국정조사권은 특정 사안에 대해 수시로 행사됩니다.",
        "tags": ["헌법", "국정감사권", "국정조사권"]
    },
    {
        "subject": "형법",
        "unit": "형법각론",
        "difficulty": 5,
        "points": 5,
        "question_type": "주관식",
        "content": "강도죄와 절도죄의 구별기준을 설명하시오.",
        "options": None,
        "correct_answer": "폭행·협박의 정도와 시기",
        "explanation": "강도죄는 폭행 또는 협박으로 타인의 재물을 강취하는 죄이고, 절도죄는 타인의 재물을 절취하는 죄입니다. 폭행·협박의 유무와 정도가 구별기준입니다.",
        "tags": ["형법각론", "강도죄", "절도죄"]
    },
    {
        "subject": "민법",
        "unit": "계약법",
        "difficulty": 3,
        "points": 4,
        "question_type": "객관식",
        "content": "계약의 성립요건으로 옳지 않은 것은?",
        "options": ["청약", "승낙", "합의", "등기"],
        "correct_answer": "등기",
        "explanation": "계약의 성립요건은 청약과 승낙의 합치(합의)입니다. 등기는 물권변동의 요건이지 계약 성립요건이 아닙니다.",
        "tags": ["계약법", "계약의 성립"]
    },
    {
        "subject": "상법",
        "unit": "상행위법",
        "difficulty": 2,
        "points": 3,
        "question_type": "객관식",
        "content": "상행위의 특칙으로 옳지 않은 것은?",
        "options": ["이자지급의무", "손해배상액의 예정", "연대책임", "과실추정"],
        "correct_answer": "과실추정",
        "explanation": "상행위의 특칙에는 이자지급의무, 손해배상액의 예정, 연대책임 등이 있으나 과실추정은 상행위의 특칙이 아닙니다.",
        "tags": ["상행위법", "상행위의 특칙"]
    }
]

# 샘플 이용권 데이터
SAMPLE_VOUCHERS = [
    {
        "name": "프로",
        "type": "pro",
        "price": 19900.0,
        "period": "month",
        "features": [
            "높은 난이도",
            "리트 과목별 N제 3회분/Day",
            "리트 단원별 N제 모든 과목, 모든 단원 1회분/Day",
            "리트 모의고사 3회/Day",
            "pdf 다운로드"
        ],
        "is_active": True
    },
    {
        "name": "베이직",
        "type": "basic",
        "price": 9900.0,
        "period": "month",
        "features": [
            "평이한 난이도",
            "리트 과목별 N제 1회/Day",
            "리트 단원별 N제 모든 과목, 모든 단원 1회분/Day",
            "리트 모의고사 1회/Day",
            "pdf 다운로드"
        ],
        "is_active": True
    },
    {
        "name": "라이트",
        "type": "light",
        "price": 4900.0,
        "period": "week",
        "features": [
            "쉬운 난이도",
            "리트 과목별 N제 1회/Day",
            "리트 단원별 N제 모든 과목, 모든 단원 1회분/Day",
            "pdf 다운로드"
        ],
        "is_active": True
    }
]

def create_sample_questions():
    """샘플 문제 생성"""
    db = SessionLocal()
    question_service = QuestionService()
    
    try:
        for question_data in SAMPLE_QUESTIONS:
            question_create = QuestionCreate(**question_data)
            question_service.create_question(question_create)
        
        print(f"✅ {len(SAMPLE_QUESTIONS)}개의 샘플 문제가 생성되었습니다.")
    except Exception as e:
        print(f"❌ 샘플 문제 생성 중 오류: {e}")
    finally:
        db.close()

def create_sample_users():
    """샘플 사용자 생성"""
    db = SessionLocal()
    auth_service = AuthService()
    
    try:
        # 샘플 사용자 1
        user1_data = UserCreate(
            email="student1@example.com",
            password="password123",
            name="김수험",
            grade="150점",
            target_grade="200점",
            study_time=120,
            learning_style="mixed"
        )
        auth_service.register_user(user1_data)
        
        # 샘플 사용자 2
        user2_data = UserCreate(
            email="student2@example.com",
            password="password123",
            name="이리트",
            grade="120점",
            target_grade="180점",
            study_time=90,
            learning_style="practical"
        )
        auth_service.register_user(user2_data)
        
        print("✅ 샘플 사용자가 생성되었습니다.")
        print("📧 테스트 계정:")
        print("   - student1@example.com / password123")
        print("   - student2@example.com / password123")
    except Exception as e:
        print(f"❌ 샘플 사용자 생성 중 오류: {e}")
    finally:
        db.close()

def create_sample_vouchers():
    """샘플 이용권 생성"""
    db = SessionLocal()
    
    try:
        for voucher_data in SAMPLE_VOUCHERS:
            voucher = Voucher(**voucher_data)
            db.add(voucher)
        
        db.commit()
        print(f"✅ {len(SAMPLE_VOUCHERS)}개의 샘플 이용권이 생성되었습니다.")
    except Exception as e:
        print(f"❌ 샘플 이용권 생성 중 오류: {e}")
        db.rollback()
    finally:
        db.close()

def create_sample_payment_methods():
    """샘플 결제 수단 생성"""
    db = SessionLocal()
    
    try:
        # 샘플 결제 수단 (테스트용)
        payment_method = PaymentMethod(
            user_id=1,  # 첫 번째 사용자
            card_type="롯데카드",
            card_number="1234********123*",
            expiry_date="12/25",
            is_default=True
        )
        db.add(payment_method)
        
        db.commit()
        print("✅ 샘플 결제 수단이 생성되었습니다.")
    except Exception as e:
        print(f"❌ 샘플 결제 수단 생성 중 오류: {e}")
        db.rollback()
    finally:
        db.close()

def main():
    """데이터베이스 초기화 및 샘플 데이터 생성"""
    print("🗄️ 데이터베이스를 초기화합니다...")
    init_db()
    
    print("📝 샘플 데이터를 생성합니다...")
    create_sample_questions()
    create_sample_users()
    create_sample_vouchers()
    create_sample_payment_methods()
    
    print("✅ 데이터베이스 초기화가 완료되었습니다!")

if __name__ == "__main__":
    main() 