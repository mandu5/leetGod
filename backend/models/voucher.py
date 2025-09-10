from sqlalchemy import Column, Integer, String, Float, DateTime, Boolean, JSON
from sqlalchemy.sql import func
from pydantic import BaseModel
from typing import List, Optional
from models.database import Base

# SQLAlchemy 모델
class Voucher(Base):
    __tablename__ = "vouchers"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(50), nullable=False)
    type = Column(String(20), nullable=False)  # pro, basic, light
    price = Column(Float, nullable=False)
    period = Column(String(20), nullable=False)  # month, week
    features = Column(JSON, nullable=False)
    is_active = Column(Boolean, default=True)

class UserVoucher(Base):
    __tablename__ = "user_vouchers"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, index=True)
    voucher_id = Column(Integer, index=True)
    is_active = Column(Boolean, default=True)
    purchased_at = Column(DateTime, default=func.now())
    expires_at = Column(DateTime, nullable=True)

class PaymentHistory(Base):
    __tablename__ = "payment_history"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, index=True)
    voucher_id = Column(Integer, index=True)
    amount = Column(Float, nullable=False)
    status = Column(String(20), nullable=False)  # completed, cancelled, pending, failed
    payment_method = Column(String(50), nullable=True)
    created_at = Column(DateTime, default=func.now())

class PaymentMethod(Base):
    __tablename__ = "payment_methods"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, index=True)
    card_type = Column(String(50), nullable=False)
    card_number = Column(String(20), nullable=False)
    expiry_date = Column(String(10), nullable=False)
    is_default = Column(Boolean, default=False)

# Pydantic 스키마
class VoucherBase(BaseModel):
    name: str
    type: str
    price: float
    period: str
    features: List[str]
    is_active: bool = True

class VoucherCreate(VoucherBase):
    pass

class VoucherResponse(VoucherBase):
    id: int

    class Config:
        from_attributes = True

class UserVoucherBase(BaseModel):
    user_id: int
    voucher_id: int
    is_active: bool = True

class UserVoucherCreate(UserVoucherBase):
    pass

class UserVoucherResponse(UserVoucherBase):
    id: int
    purchased_at: str
    expires_at: Optional[str] = None

    class Config:
        from_attributes = True

class PaymentHistoryBase(BaseModel):
    user_id: int
    voucher_id: int
    amount: float
    status: str
    payment_method: Optional[str] = None

class PaymentHistoryCreate(PaymentHistoryBase):
    pass

class PaymentHistoryResponse(PaymentHistoryBase):
    id: int
    created_at: str

    class Config:
        from_attributes = True

class PaymentMethodBase(BaseModel):
    user_id: int
    card_type: str
    card_number: str
    expiry_date: str
    is_default: bool = False

class PaymentMethodCreate(PaymentMethodBase):
    pass

class PaymentMethodResponse(PaymentMethodBase):
    id: int

    class Config:
        from_attributes = True 