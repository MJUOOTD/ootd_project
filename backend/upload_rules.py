import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import json

# 1. 서비스 계정 키를 사용하여 Firebase 앱 초기화
cred = credentials.Certificate("ootd-project_service_account_key.json")
firebase_admin.initialize_app(cred)

# 2. Firestore 데이터베이스 인스턴스 가져오기
db = firestore.client()

# 3. 로컬 JSON 파일 열기
with open('lib/outfit_rules.json', 'r', encoding='utf-8') as f:
    rules_data = json.load(f)

# 4. JSON 파일의 각 규칙(객체)에 대해 반복
for rule in rules_data:
    # 'outfit_rules_v2' 컬렉션에 새 문서로 추가
    db.collection('outfit_rules').add(rule)
    print(f"Added rule for temp range {rule['min_temp']}~{rule['max_temp']}")

print("=========================================")
print("All rules have been successfully uploaded!")
print("=========================================")