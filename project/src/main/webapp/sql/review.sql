CREATE TABLE REVIEW( -- 리뷰
   REVIEW_NUM INT PRIMARY KEY, -- 리뷰 번호 PK
   REVIEW_CONTENT VARCHAR(100), -- 리뷰 내용
   REVIEW_PRODUCT_NUM INT NOT NULL, -- 리뷰 상품 번호 FK
   REVIEW_WRITER_ID VARCHAR(50), -- 작성자 FK
   -- FK 제약조건 ON DELETE SET NULL 조건으로 인하여 NOT NULL 제약조건 삭제
   REVIEW_REGISTRATION_DATE DATE DEFAULT SYSDATE, -- 작성 날짜
   REVIEW_STAR INT NOT NULL CHECK (REVIEW_STAR BETWEEN 1 AND 5) -- 별점 남기기 // 별점은 무조건 있고 1~5 사이 (1~5만 받을 수 있도록 CHECK 제약조건 사용)
);

/*
 * 컬럼 제약조건 확인
SELECT column_name, nullable
FROM user_tab_columns
WHERE table_name = 'REVIEW';
 * NOT NULL 제약조건 삭제
ALTER TABLE REVIEW MODIFY REVIEW_WRITER_ID NULL;*/
-- 테이블 삭제
DROP TABLE REVIEW;
-- 전체 출력
SELECT * FROM REVIEW;

-- FK 제약조건 (상품)
ALTER TABLE REVIEW -- REVIEW 테이블 변경
ADD CONSTRAINT FK_REVIEW_PRODUCT_NUM -- 제약조건 추가할거야
FOREIGN KEY (REVIEW_PRODUCT_NUM) -- FK키는 REVIEW_PRODUCT_NUM
REFERENCES PRODUCT(PRODUCT_NUM) -- PRODUCT 테이블의 PRODUCT_NUM에 의존한다.
ON DELETE CASCADE; -- 상품 삭제시 리뷰도 삭제


-- FK 제약조건 (멤버)
ALTER TABLE REVIEW -- REVIEW 테이블 변경
ADD CONSTRAINT FK_REVIEW_WRITER_ID -- 제약조건 추가할거다
FOREIGN KEY (REVIEW_WRITER_ID) -- FK키는 REVIEW_WRITER_ID
REFERENCES MEMBER(MEMBER_ID) -- FK는 MEMBER 테이블의 REVIEW_WRITER_ID에 의존
ON DELETE SET NULL; -- 회원탈퇴시 리뷰는 남겨둠. 따라서 SET NULL 사용하여, 회원탈퇴시 FK값인 회원ID는 NULL로 표시됨


-- 샘플 데이터
INSERT INTO REVIEW (REVIEW_NUM, REVIEW_CONTENT, REVIEW_PRODUCT_NUM, REVIEW_WRITER_ID, REVIEW_STAR) VALUES(NVL((SELECT MAX(REVIEW_NUM) 
FROM REVIEW),0)+1,'좋아용',6,'tlsektha3852@naver.com',5);
INSERT INTO REVIEW (REVIEW_NUM, REVIEW_CONTENT, REVIEW_PRODUCT_NUM, REVIEW_WRITER_ID, REVIEW_STAR) VALUES(NVL((SELECT MAX(REVIEW_NUM) 
FROM REVIEW),0)+1,'별로',1,'zhddl@naver.com',2);
INSERT INTO REVIEW (REVIEW_NUM, REVIEW_CONTENT, REVIEW_PRODUCT_NUM, REVIEW_WRITER_ID, REVIEW_STAR) VALUES(NVL((SELECT MAX(REVIEW_NUM) 
FROM REVIEW),0)+1,'나이스!',1,'tlsektha3852@naver.com',4);
INSERT INTO REVIEW (REVIEW_NUM, REVIEW_CONTENT, REVIEW_PRODUCT_NUM, REVIEW_WRITER_ID, REVIEW_STAR) VALUES(NVL((SELECT MAX(REVIEW_NUM) 
FROM REVIEW),0)+1,'최고예요!',2,'wlsrja3852@naver.com',5);
INSERT INTO REVIEW (REVIEW_NUM, REVIEW_CONTENT, REVIEW_PRODUCT_NUM, REVIEW_WRITER_ID, REVIEW_STAR) VALUES(NVL((SELECT MAX(REVIEW_NUM) 
FROM REVIEW),0)+1,'무난!',1,'wlsrja3852@naver.com',4);	


-- 리뷰 입력
INSERT INTO REVIEW (REVIEW_NUM, REVIEW_CONTENT, REVIEW_PRODUCT_NUM, REVIEW_WRITER_ID, REVIEW_STAR) VALUES(COALESCE((SELECT MAX(REVIEW_NUM) 
FROM REVIEW),0)+1, ?,?,?,?);


-- 리뷰 수정
-- 리뷰 내용과 별점 같이 수정
UPDATE REVIEW SET REVIEW_CONTENT=?, REVIEW_STAR=? WHERE REVIEW_NUM=?;

-- 리뷰 삭제
DELETE FROM REVIEW WHERE REVIEW_NUM=?;


-- 리뷰 전체 출력 (최신순)
-- 리뷰 번호 / 리뷰 내용 / 리뷰 작성일 / 별점 / * 리뷰 작성자 ID / *리뷰 작성자 닉네임 / * 작성자 레벨 / * 작성자 프로필
-- C에게 상품 번호를 받아와서 해당 리뷰의 전체 목록을 보여준다.
-- 작성자의 ID, 닉네임의 경우 MEMBER 테이블와 JOIN하여 두 테이블의 정보가 같은 경우 결합시킨다.
SELECT R.REVIEW_NUM, R.REVIEW_CONTENT, R.REVIEW_REGISTRATION_DATE, R.REVIEW_STAR, COALESCE(R.REVIEW_WRITER_ID,'탈퇴한 회원입니다.'), COALESCE(M.MEMBER_NICKNAME,'탈퇴한 회원입니다.'),COALESCE(ML.LV_COUNT,1) AS MEMBER_LEVEL, M.MEMBER_PROFILE
FROM REVIEW R
JOIN MEMBER M ON R.REVIEW_WRITER_ID = M.MEMBER_ID
LEFT JOIN (SELECT B.BOARD_WRITER_ID,COUNT(B.BOARD_WRITER_ID) AS LV_COUNT FROM BOARD B GROUP BY B.BOARD_WRITER_ID)ML ON R.REVIEW_WRITER_ID=ML.BOARD_WRITER_ID
WHERE R.REVIEW_PRODUCT_NUM = ? ORDER BY R.REVIEW_NUM DESC;

-- 리뷰 전체 출력 (별점 높은 순)
-- 리뷰 번호 / 리뷰 내용 / 리뷰 작성일 / 별점 / * 리뷰 작성자 ID / *리뷰 작성자 닉네임 / * 작성자 레벨
SELECT R.REVIEW_NUM, R.REVIEW_CONTENT, R.REVIEW_REGISTRATION_DATE, R.REVIEW_STAR, COALESCE(R.REVIEW_WRITER_ID,'탈퇴한 회원입니다.'), COALESCE(M.MEMBER_NICKNAME,'탈퇴한 회원입니다.'),COALESCE(ML.LV_COUNT,1) AS MEMBER_LEVEL, M.MEMBER_PROFILE
FROM REVIEW R
JOIN MEMBER M ON R.REVIEW_WRITER_ID = M.MEMBER_ID
LEFT JOIN (SELECT B.BOARD_WRITER_ID,COUNT(B.BOARD_WRITER_ID) AS LV_COUNT FROM BOARD B GROUP BY B.BOARD_WRITER_ID)ML ON R.REVIEW_WRITER_ID=ML.BOARD_WRITER_ID
WHERE R.REVIEW_PRODUCT_NUM = ? ORDER BY R.REVIEW_STAR DESC;


-- 리뷰 전체 출력 (별점 낮은 순)
-- 리뷰 번호 / 리뷰 내용 / 리뷰 작성일 / 별점 / * 리뷰 작성자 ID / *리뷰 작성자 닉네임 / * 작성자 레벨
SELECT R.REVIEW_NUM, R.REVIEW_CONTENT, R.REVIEW_REGISTRATION_DATE, R.REVIEW_STAR, COALESCE(R.REVIEW_WRITER_ID,'탈퇴한 회원입니다.'), COALESCE(M.MEMBER_NICKNAME,'탈퇴한 회원입니다.'),COALESCE(ML.LV_COUNT,1) AS MEMBER_LEVEL, M.MEMBER_PROFILE
FROM REVIEW R
JOIN MEMBER M ON R.REVIEW_WRITER_ID = M.MEMBER_ID
LEFT JOIN (SELECT B.BOARD_WRITER_ID,COUNT(B.BOARD_WRITER_ID) AS LV_COUNT FROM BOARD B GROUP BY B.BOARD_WRITER_ID)ML ON R.REVIEW_WRITER_ID=ML.BOARD_WRITER_ID
WHERE R.REVIEW_PRODUCT_NUM = ? ORDER BY R.REVIEW_STAR;


