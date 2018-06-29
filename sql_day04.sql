---- JOIN 계속..
-- EQUI-조인 구문 구조

-- 1. 오라클 전용 조인 구조
SELECT [별칭1.]컬럼명1, [별칭2.]컬럼명2 [, ...]
  FROM 테이블1 별칭1, 테이블2 별칭2 [, ....]
 WHERE 별칭1.공통컬럼1 = 별칭2.공통컬럼1  -- 조인 조건을 WHERE 에 작성
  [AND 별칭1.공통컬럼2 = 별칭n.공통컬럼2] -- FROM 에 나열된 테이블이 2개가 넘을 때 조인 조건 추가
  [AND ... 추가 가능한 일반 조건들 등장]
;  
  ---------------------------------------------------

-- 2. NATURAL JOIN 을 사용하는 구조
SELECT [별칭1.]컬럼명1, [별칭2.]컬럼명2 [, ...]
  FROM 테이블1 별칭1 NATURAL JOIN 테이블2 별칭2
                    [NATURAL JOIN 테이블n 별칭n]
;                    
  ---------------------------------------------------

-- 3. JOIN ~ USING 을 사용하는 구조 : 여러 테이블에서 공통컬럼 이름이 동일해야 함
SELECT [별칭1.]컬럼명1, [별칭2.]컬럼명2 [, ...]
  FROM 테이블1 별칭1 JOIN 테이블2 별칭2 USING (공통컬럼) -- 공통컬럼에 별칭 사용하지 않음
;  
  ---------------------------------------------------
  
-- 4. JOIN ~ ON 을 사용하는 구조 : 표준 SQL 구문
SELECT [별칭1.]컬럼명1, [별칭2.]컬럼명2 [, ...]
  FROM 테이블1 별칭1 JOIN 테이블2 별칭2 ON (별칭1.공통컬럼2 = 별칭n.공통컬럼2)
                    [JOIN 테이블n 별칭n ON (별칭1.공통컬럼n = 별칭n.공통컬럼n)]
;                    
----------------------------------------------------------------------
---- 4) NON-EQUI JOIN : WHERE 조건절에 join attribute 사용하는 대신
--                      다른 비교 연산자를 사용하여 여러 테이블을 엮는 기법

-- 문제 ) emp, salgrade 테이블을 사용하여 직원의 급여에 따른 등급을 함께 조회
--        emp 테이블에는 salgrade 테이블과 연결할 수 있는 동일한 값이 없음

SELECT e.EMPNO
     , e.ENAME
     , e.SAL
     , s.grade     
  FROM emp e
     , salgrade s
 WHERE e.SAL BETWEEN s.LOSAL AND s.HISAL
;

---- 5) OUTER JOIN : 조인 대상 테이블 중 공통 컬럼에 NULL 값인 데이터의 경우도 출력을 원할 때

--  연산자 : (+), LEFT OUTER JOIN, RIGHT OUTER JOIN

------ 1. (+) : 오라클이 사용하는 전통적인 OUTER JOIN 연산자
--              왼쪽, 오른쪽 어느쪽에나 NULL 값을 출력하기 원하는 쪽에 
--              붙여서 사용

--     2. (+) 연산자 사용시 JOIN 구문 구조
SELECT ......
  FROM 테이블1 별칭1, 테이블2 별칭2
 WHERE 별칭1.공통컬럼(+) = 별칭2.공통컬럼 /* RIGHT OUTER JOIN, 왼쪽 테이블의 NULL 데이터 출력*/
[WHERE 별칭1.공통컬럼 = 별칭2.공통컬럼(+) /* LEFT OUTER JOIN, 오른쪽 테이블의 NULL 데이터 출력*/]
;
--        RIGHT OUTER JOIN ~ ON 구문 구조
SELECT ......
  FROM 테이블1 별칭1 RIGHT OUTER JOIN 테이블2 별칭2
    ON 별칭1.공통컬럼 = 별칭2.공통컬럼
;
--        LEFT OUTER JOIN ~ ON 구문 구조
SELECT ......
  FROM 테이블1 별칭1 LEFT OUTER JOIN 테이블2 별칭2
    ON 별칭1.공통컬럼 = 별칭2.공통컬럼
;
-----------------------------------------------------------
-- 문제) 직원 중에 부서가 배치되지 않은 사람이 있을 때
-- 1. 일반 조인(EQUI-JOIN)을 걸면 조회가 되지 않는다.
SELECT e.EMPNO
     , e.ENAME
     , e.DEPTNO
     , d.DNAME
  FROM emp e
     , dept d
 WHERE e.DEPTNO = d.DEPTNO     
;

-- 2. OUTER JOIN (+) 연산자로 해결
SELECT e.EMPNO
     , e.ENAME
     , e.DEPTNO
     , d.DNAME
  FROM emp e
     , dept d
 WHERE e.DEPTNO = d.DEPTNO(+) 
;
-- (+) 연산자는 오른쪽에 붙이고 이는 NULL 상태로 출력될 테이블을 결정
-- 전체 데이터를 기준삼는 테이블이 왼쪽이기 때문에 LEFT OUTER JOIN 발생

-- 3. LEFT OUTER JOIN ~ ON 으로
SELECT e.EMPNO
     , e.ENAME
     , e.DEPTNO
     , d.DNAME
  FROM emp e LEFT OUTER JOIN dept d
    ON e.DEPTNO = d.DEPTNO
;

-- 문제) 아직 아무도 배치되지 않은 부서가 있어도
--       부서를 다 조회하고 싶다면
-- 1. (+) 연산자로 해결
SELECT e.EMPNO
     , e.ENAME
     , e.DEPTNO
     , '|'
     , d.DEPTNO
     , d.DNAME
  FROM emp e
     , dept d
 WHERE e.DEPTNO(+) = d.DEPTNO 
; 

-- 2. RIGHT OUTER JOIN ~ ON 으로 해결
SELECT e.EMPNO
     , e.ENAME
     , e.DEPTNO
     , '|'
     , d.DEPTNO
     , d.DNAME
  FROM emp e RIGHT OUTER JOIN dept d
    ON e.DEPTNO = d.DEPTNO 
; 

-- 문제) 부서배치가 안된 직원도 보고 싶고
--       직원이 아직 아무도 없는 부서도 모두 싶을 때
--       즉, 양쪽 모두에 존재하는 NULL 값을들 모두 한번에 조회하려면 어떻게 해야 하는가?
-- 1. (+) 연산자로는 양쪽 아우터 조인 불가능
SELECT e.EMPNO
     , d.DNAME
  FROM emp e           -- ===> ORA-01468: a predicate may reference only one outer-joined table
     , dept d
 WHERE e.DEPTNO(+) = d.DEPTNO(+)
; 

-- 2. FULL OUTER JOIN ~ ON 구문으로 지원
SELECT e.EMPNO
     , e.ENAME
     , d.DNAME
  FROM emp e FULL OUTER JOIN dept d
    ON e.DEPTNO = d.DEPTNO
; 

---- 6) SELF JOIN : 한 테이블 내에서 자기 자신의 컬럼 끼리 연결하여 새 행을 만드는 기법
-- 문제) emp 테이블에서 mgr 에 해당하는 상사의 이름을 같이 조회하려면
SELECT e1.EMPNO  "직원 사번"
     , e1.ENAME  "지원 이름"
     , e1.MGR    "상사 사번"
     , e2.ENAME  "상사 이름"
  FROM emp e1
     , emp e2
 WHERE e1.MGR = e2.EMPNO     
;     
-- 상사가 없는 직원도 조회하고 싶다. 
-- a) e1 테이블이 기준 => LEFT OUTER JOIN
-- b) (+) 기호를 오른쪽에 붙인다.
SELECT e1.EMPNO  "직원 사번"
     , e1.ENAME  "지원 이름"
     , e1.MGR    "상사 사번"
     , e2.ENAME  "상사 이름"
  FROM emp e1
     , emp e2
 WHERE e1.MGR = e2.EMPNO(+)
;    

SELECT e1.EMPNO  "직원 사번"
     , e1.ENAME  "지원 이름"
     , e1.MGR    "상사 사번"
     , e2.ENAME  "상사 이름"
  FROM emp e1 LEFT OUTER JOIN emp e2
    ON e1.MGR = e2.EMPNO
;    

-- 부하 직원이 없는 직원들 조회
SELECT e1.EMPNO  "직원 사번"
     , e1.ENAME  "지원 이름"
     , e1.MGR    "상사 사번"
     , e2.ENAME  "상사 이름"
  FROM emp e1
     , emp e2
 WHERE e1.MGR(+) = e2.EMPNO
; 

SELECT e1.EMPNO  "직원 사번"
     , e1.ENAME  "지원 이름"
     , e1.MGR    "상사 사번"
     , e2.ENAME  "상사 이름"
  FROM emp e1 RIGHT OUTER JOIN emp e2
    ON e1.MGR = e2.EMPNO
; 

--------------- 7. 조인과 서브쿼리
-- (2) 서브쿼리 : SUB-QUERY
--                SELECT, FROM, WHERE 절에 사용할 수 있다.

-- 문제) BLAKE와 직무가 동일한 직원의 정보를 조회
-- 1. BLAKE 의 직무를 조회
SELECT e.JOB
  FROM emp e
 WHERE e.ENAME = 'BLAKE' 
;  
-- ==> 'MANAGER' 결과를 얻어냄

-- 2. 1의 결과를 WHERE 조건 절에 사용하는 메인 쿼리 작성
SELECT e.EMPNO
     , e.ENAME
     , e.JOB
  FROM emp e
 WHERE e.JOB = (SELECT e.JOB
                  FROM emp e
                 WHERE e.ENAME = 'BLAKE')
;
-- ==> 메인 쿼리의 WHERE 절에 () 안에 전달되는 값이 1의 결과인 
--     'MANAGER' 라는 값이다.

---------------------------------------------------------------
-- 서브쿼리 실습
-- 1. 이 회사의 평균 급여보다 급여가 
--    큰 직원들이 목록을 조회
--    (사번, 이름, 급여)
-- 2. 급여가 평균 급여보다 크면서 
--    사번이 7700 번보다 높은 직원 조회
--    (사번, 이름, 급여)
-- 3. 각 직무별로 최대 급여를 받는 
--    직원 목록을 조회
--    (사번, 이름, 직무, 급여)
-- 4. 각 월별 입사인원을 세로로 출력













