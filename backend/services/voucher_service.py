from sqlalchemy.orm import Session
from models.voucher import Voucher, UserVoucher, PaymentHistory, PaymentMethod
from models.user import User
from typing import List, Optional
from datetime import datetime, timedelta

class VoucherService:
    def __init__(self, db: Session):
        self.db = db

    def get_user_voucher_info(self, user_id: int) -> dict:
        """사용자의 현재 이용권 정보를 가져옵니다."""
        user_voucher = self.db.query(UserVoucher).filter(
            UserVoucher.user_id == user_id,
            UserVoucher.is_active == True
        ).first()

        if not user_voucher:
            return {"voucher": None}

        voucher = self.db.query(Voucher).filter(Voucher.id == user_voucher.voucher_id).first()
        
        return {
            "voucher": {
                "id": str(voucher.id),
                "name": voucher.name,
                "type": voucher.type,
                "price": voucher.price,
                "period": voucher.period,
                "features": voucher.features,
                "is_active": voucher.is_active
            }
        }

    def get_payment_history(self, user_id: int) -> List[dict]:
        """사용자의 결제 내역을 가져옵니다."""
        payments = self.db.query(PaymentHistory).filter(
            PaymentHistory.user_id == user_id
        ).order_by(PaymentHistory.created_at.desc()).all()

        result = []
        for payment in payments:
            voucher = self.db.query(Voucher).filter(Voucher.id == payment.voucher_id).first()
            result.append({
                "id": str(payment.id),
                "voucher_name": voucher.name if voucher else "알 수 없음",
                "amount": payment.amount,
                "date": payment.created_at.isoformat(),
                "status": payment.status
            })

        return result

    def get_payment_method(self, user_id: int) -> Optional[dict]:
        """사용자의 결제 수단을 가져옵니다."""
        payment_method = self.db.query(PaymentMethod).filter(
            PaymentMethod.user_id == user_id,
            PaymentMethod.is_default == True
        ).first()

        if not payment_method:
            return None

        return {
            "id": str(payment_method.id),
            "card_type": payment_method.card_type,
            "card_number": payment_method.card_number,
            "expiry_date": payment_method.expiry_date
        }

    def get_available_vouchers(self) -> List[dict]:
        """이용 가능한 이용권 목록을 가져옵니다."""
        vouchers = self.db.query(Voucher).filter(Voucher.is_active == True).all()
        
        result = []
        for voucher in vouchers:
            result.append({
                "id": str(voucher.id),
                "name": voucher.name,
                "type": voucher.type,
                "price": voucher.price,
                "period": voucher.period,
                "features": voucher.features,
                "is_active": voucher.is_active
            })

        return result

    def purchase_voucher(self, user_id: int, voucher_id: int, payment_method_id: int) -> dict:
        """이용권을 구매합니다."""
        # 기존 활성 이용권 비활성화
        existing_voucher = self.db.query(UserVoucher).filter(
            UserVoucher.user_id == user_id,
            UserVoucher.is_active == True
        ).first()
        
        if existing_voucher:
            existing_voucher.is_active = False

        # 새 이용권 구매
        voucher = self.db.query(Voucher).filter(Voucher.id == voucher_id).first()
        if not voucher:
            raise ValueError("이용권을 찾을 수 없습니다.")

        # 만료일 계산
        expires_at = None
        if voucher.period == "month":
            expires_at = datetime.now() + timedelta(days=30)
        elif voucher.period == "week":
            expires_at = datetime.now() + timedelta(days=7)

        user_voucher = UserVoucher(
            user_id=user_id,
            voucher_id=voucher_id,
            is_active=True,
            expires_at=expires_at
        )
        self.db.add(user_voucher)

        # 결제 내역 기록
        payment_history = PaymentHistory(
            user_id=user_id,
            voucher_id=voucher_id,
            amount=voucher.price,
            status="completed",
            payment_method="card"
        )
        self.db.add(payment_history)

        self.db.commit()

        return {
            "success": True,
            "message": f"{voucher.name} 이용권이 구매되었습니다."
        }

    def cancel_voucher(self, user_id: int) -> dict:
        """이용권을 해지합니다."""
        user_voucher = self.db.query(UserVoucher).filter(
            UserVoucher.user_id == user_id,
            UserVoucher.is_active == True
        ).first()

        if not user_voucher:
            raise ValueError("활성 이용권이 없습니다.")

        user_voucher.is_active = False
        self.db.commit()

        return {
            "success": True,
            "message": "이용권이 해지되었습니다."
        } 