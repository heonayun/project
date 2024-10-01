CREATE TABLE RESERVATION( -- 예약
   RESERVATION_NUM INT PRIMARY KEY, -- 예약 번호 PK
   RESERVATION_PAYMENT_NUM INT NOT NULL, -- 결제 번호 FK
   RESERVATION_REGISTRATION_DATE DATE NOT NULL, -- 예약 날짜
   RESERVATION_STATUS VARCHAR(20) DEFAULT '예약완료' NOT NULL CHECK(RESERVATION_STATUS IN('예약완료','예약취소')) --예약 상태
);

-- 테이블 삭제
DROP TABLE RESERVATION CASCADE CONSTRAINT;
-- 테이블 조회
SELECT * FROM RESERVATION;


-- 컬럼 확인
SELECT COLUMN_NAME, DATA_TYPE, DATA_LENGTH, DATA_DEFAULT, NULLABLE
FROM USER_TAB_COLUMNS
WHERE TABLE_NAME = 'RESERVATION';


-- 샘플
INSERT INTO RESERVATION (RESERVATION_NUM,RESERVATION_PAYMENT_NUM,RESERVATION_REGISTRATION_DATE) VALUES(COALESCE((SELECT MAX(RESERVATION_NUM) FROM RESERVATION),0)+1,1,'2024-09-23');
INSERT INTO RESERVATION (RESERVATION_NUM,RESERVATION_PAYMENT_NUM,RESERVATION_REGISTRATION_DATE) VALUES(COALESCE((SELECT MAX(RESERVATION_NUM) FROM RESERVATION),0)+1,2,'2024-09-13');
INSERT INTO RESERVATION (RESERVATION_NUM,RESERVATION_PAYMENT_NUM,RESERVATION_REGISTRATION_DATE) VALUES(COALESCE((SELECT MAX(RESERVATION_NUM) FROM RESERVATION),0)+1,3,'2024-09-15');
INSERT INTO RESERVATION (RESERVATION_NUM,RESERVATION_PAYMENT_NUM,RESERVATION_REGISTRATION_DATE) VALUES(COALESCE((SELECT MAX(RESERVATION_NUM) FROM RESERVATION),0)+1,4,'2024-09-10');
INSERT INTO RESERVATION (RESERVATION_NUM,RESERVATION_PAYMENT_NUM,RESERVATION_REGISTRATION_DATE) VALUES(COALESCE((SELECT MAX(RESERVATION_NUM) FROM RESERVATION),0)+1,1,'2024-09-30');


-- FK제약조건 (결제)
ALTER TABLE RESERVATION /*RESERVATION 테이블 변경*/
ADD CONSTRAINT FK_RESERVATION_PAYMENT_NUM /*FK제약조건을 추가한다.*/
FOREIGN KEY (RESERVATION_PAYMENT_NUM) /*FK는 RESERVATION_PAYMENT_NUM*/
REFERENCES PAYMENT(PAYMENT_NUM); /*그 FK키는 PAYMENT 테이블의 PAYMENT_NUM에 의존한다.*/
-- ON DELETE절은  NO ACTION == 부모 테이블(PAYMENT)에서 데이터가 삭제될 경우, 자식 테이블(RESERVATION)에서 참조하는 데이터 있으면 삭제 안됨
-- 오라클 버전에 따라 달라지는데 MySQL이랑 합병 전에는 NO ACTION, 이후로는 RESTRICT 사용
-- 결론 : RESTRICT가 맞다! 하지만 DEFAULT 설정이기 때문에 별도로 추가하지 않아도 된다.


-- 예약 생성
INSERT INTO RESERVATION (RESERVATION_NUM,RESERVATION_PAYMENT_NUM,RESERVATION_REGISTRATION_DATE) 
VALUES(COALESCE((SELECT MAX(RESERVATION_NUM) FROM RESERVATION),0)+1,?,?);


-- 예약 내용 변경 (예약 상태 변경)
UPDATE RESERVATION SET RESERVATION_STATUS = ? WHERE RESERVATION_NUM = ?;


-- 내 예약 내역 전체보기
-- 예약 번호 / 예약일자(상품 이용일) / 예약상태 / *상품번호 / *상품명 / *결제 금액
-- 어차피 내가 탈퇴한 상태면 예약내역 볼 일 없음
SELECT R.RESERVATION_NUM, R.RESERVATION_REGISTRATION_DATE, R.RESERVATION_STATUS, COALESCE(PR.PRODUCT_NUM,0) AS PRODUCT_NUM, COALESCE(PR.PRODUCT_NAME,'존재하지 않는 상품입니다.') AS PRODUCT_NAME, P.PAYMENT_PRICE
FROM RESERVATION R
JOIN PAYMENT P ON R.RESERVATION_PAYMENT_NUM = P.PAYMENT_NUM
LEFT JOIN PRODUCT PR ON P.PAYMENT_PRODUCT_NUM = PR.PRODUCT_NUM
WHERE P.PAYMENT_MEMBER_ID = ? ORDER BY R.RESERVATION_REGISTRATION_DATE DESC;
-- 예약일 기준 내림차순
/*
SELECT P.PAYMENT_NUM, R.RESERVATION_NUM, R.RESERVATION_REGISTRATION_DATE, R.RESERVATION_STATUS, COALESCE(PR.PRODUCT_NUM,0) AS PRODUCT_NUM, COALESCE(PR.PRODUCT_NAME,'존재하지 않는 상품입니다.') AS PRODUCT_NAME, P.PAYMENT_PRICE, P.PAYMENT_REGISTRATION_DATE,\r\n"
			+ "P.PAYMENT_METHOD, P.PAYMENT_STATUS,COALESCE(P.PAYMENT_MEMBER_ID,'탈퇴한 회원입니다.') AS PAYMENT_MEMBER_ID, COALESCE(M.MEMBER_NAME,'탈퇴한 회원입니다.') AS MEMBER_NAME,COALESCE(M.MEMBER_PHONE,'탈퇴한 회원입니다.') AS MEMBER_PHONE\r\n"
			+ "FROM RESERVATION R\r\n"
			+ "JOIN PAYMENT P ON R.RESERVATION_PAYMENT_NUM = P.PAYMENT_NUM\r\n"
			+ "LEFT JOIN PRODUCT PR ON P.PAYMENT_PRODUCT_NUM = PR.PRODUCT_NUM\r\n"
			+ "LEFT JOIN MEMBER M ON P.PAYMENT_MEMBER_ID = M.MEMBER_ID\r\n"
			+ "WHERE R.RESERVATION_NUM = ?
 */

-- 내 예약 내역 상세보기 (결제 내역 같이 보여야 함)
-- 예약 번호 / 예약일자(상품 이용일) / 예약상태 / *상품번호 / *상품명 / *결제 금액 / *결제일 / *결제 방법 / *결제 상태 / *결제자(==예약자) ID  / *예약자 성명 / *예약자 핸드폰번호 
SELECT R.RESERVATION_NUM, R.RESERVATION_REGISTRATION_DATE, R.RESERVATION_STATUS, COALESCE(PR.PRODUCT_NUM,0) AS PRODUCT_NUM, COALESCE(PR.PRODUCT_NAME,'존재하지 않는 상품입니다.') AS PRODUCT_NAME, P.PAYMENT_PRICE, P.PAYMENT_REGISTRATION_DATE,
P.PAYMENT_METHOD, P.PAYMENT_STATUS,COALESCE(P.PAYMENT_MEMBER_ID,'탈퇴한 회원입니다.') AS PAYMENT_MEMBER_ID, COALESCE(M.MEMBER_NAME,'탈퇴한 회원입니다.') AS MEMBER_NAME,COALESCE(M.MEMBER_PHONE,'탈퇴한 회원입니다.') AS MEMBER_PHONE
FROM RESERVATION R
JOIN PAYMENT P ON R.RESERVATION_PAYMENT_NUM = P.PAYMENT_NUM
LEFT JOIN PRODUCT PR ON P.PAYMENT_PRODUCT_NUM = PR.PRODUCT_NUM
LEFT JOIN MEMBER M ON P.PAYMENT_MEMBER_ID = M.MEMBER_ID
WHERE R.RESERVATION_NUM = ?;


-- 마지막에 저장된 PK 번호 보여주기
-- 예약완료시 바로 예약페이지로 넘어가기 위해 예약테이블의 PK 번호가 필요
-- 서브쿼리를 사용해서 게시글 내림차순으로 정렬하고, ROWNUM(가상의 번호를 설정해줌)을 이용해서 1개의 값을 반환한다.
SELECT RESERVATION_NUM FROM (SELECT RESERVATION_NUM FROM RESERVATION ORDER BY RESERVATION_NUM DESC) WHERE ROWNUM=1;


SELECT 
    P.PAYMENT_NUM, R.RESERVATION_NUM, R.RESERVATION_REGISTRATION_DATE, R.RESERVATION_STATUS,
    COALESCE(PR.PRODUCT_NUM, 0) AS PRODUCT_NUM,
    COALESCE(PR.PRODUCT_NAME, '존재하지 않는 상품입니다.') AS PRODUCT_NAME,
    P.PAYMENT_PRICE, P.PAYMENT_REGISTRATION_DATE, P.PAYMENT_METHOD, P.PAYMENT_STATUS,
    COALESCE(P.PAYMENT_MEMBER_ID, '탈퇴한 회원입니다.') AS PAYMENT_MEMBER_ID,
    COALESCE(M.MEMBER_NAME, '탈퇴한 회원입니다.') AS MEMBER_NAME,
    COALESCE(M.MEMBER_PHONE, '탈퇴한 회원입니다.') AS MEMBER_PHONE,
    F.FILE_NAME, F.FILE_EXTENSION, F.FILE_DIR
FROM 
    RESERVATION R
JOIN 
    PAYMENT P ON R.RESERVATION_PAYMENT_NUM = P.PAYMENT_NUM
LEFT JOIN 
    PRODUCT PR ON P.PAYMENT_PRODUCT_NUM = PR.PRODUCT_NUM
LEFT JOIN 
    MEMBER M ON P.PAYMENT_MEMBER_ID = M.MEMBER_ID
LEFT JOIN (
    SELECT 
        FILE_NAME, 
        FILE_EXTENSION, 
        FILE_DIR,
        PRODUCT_ITEM_NUM,
        ROW_NUMBER() OVER (PARTITION BY PRODUCT_ITEM_NUM ORDER BY FILE_NUM) AS ROW_NUM
    FROM IMAGEFILE
) F ON F.ROW_NUM = 1 AND PR.PRODUCT_NUM = F.PRODUCT_ITEM_NUM
WHERE R.RESERVATION_NUM = 1;


