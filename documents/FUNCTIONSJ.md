# �ӎ�
�ܖ��搶�̊֐������V�X�e���̃e�L�X�g���ꕔ���ρA���p�����Ă��������܂����B���肪�Ƃ��������܂��B

# Easy-ISLisp �֐��ꗗ *�g�������܂�

```
�֐�: BASIC-ARRAY-P
�d�l: (BASIC-ARRAY-P OBJ) ---> BOOLEAN
����: obj ���z��܂��͕�����, �x�N�^ ���ǂ������`�F�b�N����

�֐�: BASIC-ARRAY*-P
�d�l: (BASIC-ARRAY*-P OBJ) ---> BOOLEAN
����: obj ���������z��ł��邩���`�F�b�N����

�֐�: GENERAL-ARRAY*-P
�d�l: (GENERAL-ARRAY*-P OBJ) ---> BOOLEAN
����: obj ���������z��ł��邩���`�F�b�N����

�֐�: CREATE-ARRAY
�d�l: (CREATE-ARRAY DIMENSIONS INITIAL-ELEMENT +) ---> <BASIC-ARRAY>
����: �z��𐶐�����

�֐�: AREF
�d�l: (AREF BASIC-ARRAY Z *) ---> <OBJECT>
����: �z�� basic-array �� z �Ԗڂ̗v�f�����o��

�֐�: GAREF
�d�l: (GAREF GENERAL-ARRAY Z *) ---> <OBJECT>
����: �z�� general-array �� z �Ԗڂ̗v�f�����o��

�֐�: SET-AREF
�d�l: (SET-AREF OBJ BASIC-ARRAY Z *) ---> <OBJECT>
����: �z�� basic-array �� z �Ԗڂɗv�f obj ���Z�b�g����

�֐�: SET-GAREF
�d�l: (SET-GAREF OBJ GENERAL-ARRAY Z *) ---> <OBJECT>
����: �z�� general-array �� z �Ԗڂɗv�f obj ���Z�b�g����

�֐�: ARRAY-DIMENSIONS
�d�l: (ARRAY-DIMENSIONS BASIC-ARRAY) ---> <LIST>
����: �z�� basic-array �̎��������X�g�ŕԂ�

�֐�: CHARACTERP
�d�l: (CHARACTERP OBJ) ---> BOOLEAN
����: obj �������ł��邩���`�F�b�N����

�֐�: CHAR=
�d�l: (CHAR= CHAR1 CHAR2) ---> BOOLEAN
����: char1 �� char2 �̕����������������`�F�b�N����

�֐�: CHAR/=
�d�l: (CHAR/= CHAR1 CHAR2) ---> BOOLEAN
����: char1 �� char2 �̕������������Ȃ������`�F�b�N����

�֐�: CHAR<
�d�l: (CHAR< CHAR1 CHAR2) ---> BOOLEAN
����: char1 �̕����R�[�h�� char2 �����傫�������`�F�b�N����

�֐�: CHAR>
�d�l: (CHAR> CHAR1 CHAR2) ---> BOOLEAN
����: char1 �̕����R�[�h�� char2 ���������������`�F�b�N����

�֐�: CHAR<=
�d�l: (CHAR<= CHAR1 CHAR2) ---> BOOLEAN
����: char1 �̕����R�[�h�� char2 �����傫�����܂��͓����������`�F�b�N����

�֐�: CHAR>=
�d�l: (CHAR>= CHAR1 CHAR2) ---> BOOLEAN
����: char1 �̕����R�[�h�� char2 �����������܂��͓����������`�F�b�N����

�֐�: ERROR
�d�l: (ERROR ERROR-STRING OBJ *) ---> <OBJECT>
����: �G���[���V�O�i������

�֐�: CERROR
�d�l: (CERROR CONTINUE-STRING ERROR-STRING OBJ *) ---> <OBJECT>
����: �p���\�ȃG���[���V�O�i������

�֐�: SIGNAL-CONDITION
�d�l: (SIGNAL-CONDITION CONDITION CONTINUABLE) ---> <OBJECT>
����: �R���f�B�V�����𑀍삷�邽�߂ɃV�O�i������

�֐�: IGNORE-ERRORS
�d�l: (IGNORE-ERRORS FORM *) ---> <OBJECT>
����: �G���[���o�Ă���������(����`��)

�֐�: REPORT-CONDITION
�d�l: (REPORT-CONDITION CONDITION STREAM) ---> <CONDITION>
����: �R���f�B�V���� condition ���X�g���[�� stream �Ƀ��|�[�g����

�֐�: CONDITION-CONTINUABLE
�d�l: (CONDITION-CONTINUABLE CONDITION) ---> <OBJECT>
����: �p���\�����`�F�b�N����

�֐�: CONTINUE-CONDITION
�d�l: (CONTINUE-CONDITION CONDITION VALUE +) ---> <OBJECT>
����: �R���f�B�V��������p������

�֐�: WITH-HANDLER
�d�l: (WITH-HANDLER HANDLER FORM *) ---> <OBJECT>
����: �n���h����]�����ăt�H�[�������s����(����`��)

�֐�: ARITHMETIC-ERROR-OPERATION
�d�l: (ARITHMETIC-ERROR-OPERATION ARITHMETIC-ERROR) ---> <FUNCTION>
����: �Z�p���Z�G���[�̃I�y���[�^��Ԃ�

�֐�: ARITHMETIC-ERROR-OPERANDS
�d�l: (ARITHMETIC-ERROR-OPERANDS ARITHMETIC-ERROR) ---> <LIST>
����: �Z�p���Z�G���[�̃I�y�����h��Ԃ�

�֐�: DOMAIN-ERROR-OBJECT
�d�l: (DOMAIN-ERROR-OBJECT DOMAIN-ERROR) ---> <OBJECT>
����: �h���C���G���[ domain-error �Ő������ꂽ�I�u�W�F�N�g��Ԃ�

�֐�: DOMAIN-ERROR-EXPECTED-CLASS
�d�l: (DOMAIN-ERROR-EXPECTED-CLASS DOMAIN-ERROR) ---> <CLASS>�@
����: �h���C���G���[ domain-error �Ő������ꂽ�]�܂��������h���C����Ԃ�

�֐�: PARSE-ERROR-STRING
�d�l: (PARSE-ERROR-STRING PARSE-ERROR) ---> <STRING>
����: ��̓G���[ parse-error �Ő������ꂽ�������Ԃ�

�֐�: PARSE-ERROR-EXPECTED-CLASS
�d�l: (PARSE-ERROR-EXPECTED-CLASS PARSE-ERROR) ---> <CLASS>
����: ��̓G���[ parse-error �Ő������ꂽ�]�܂����N���X��Ԃ�

�֐�: SIMPLE-ERROR-FORMAT-STRING
�d�l: (SIMPLE-ERROR-FORMAT-STRING SIMPLE-ERROR) ---> <STRING>
����: simple-error �Ő������ꂽ�������Ԃ�

�֐�: SIMPLE-ERROR-FORMAT-ARGUMENTS
�d�l: (SIMPLE-ERROR-FORMAT-ARGUMENTS SIMPLE-ERROR) ---> <LIST>
����: simple-error �Ő������ꂽ�������X�g��Ԃ�

�֐�: STREAM-ERROR-STREAM
�d�l: (STREAM-ERROR-STREAM STREAM-ERROR) ---> <STREAM>
����: �X�g���[���G���[ stream-error �Ő������ꂽ�X�g���[����Ԃ�

�֐�: UNDEFINED-ENTITY-NAME
�d�l: (UNDEFINED-ENTITY-NAME UNDEFINED-ENTITY) ---> <SYMBOL>
����: ����`�G���e�B�e�B undefined-entity �Ő������ꂽ�V���{����Ԃ�

�֐�: UNDEFINED-ENTITY-NAMESPACE
�d�l: (UNDEFINED-ENTITY-NAMESPACE UNDEFINED-ENTITY) ---> <SYMBOL>
����: ����`�G���e�B�e�B undefined-entity �Ő������ꂽ���O��Ԃ�Ԃ�

�֐�: QUOTE
�d�l: (QUOTE OBJ) ---> <OBJECT>
����: obj �̎Q�Ƃ�Ԃ�(����`��)

�֐�: SETQ
�d�l: (SETQ VAR FORM) ---> <OBJECT>
����: �ϐ� var �Ƀt�H�[�� form �̕]�����ʂ�������(����`��)

�֐�: SETF
�d�l: (SETF PLACE FORM) ---> <OBJECT>
����: �ꏊ place �Ƀt�H�[�� form �̕]�����ʂ�������(����`��)

�֐�: LET
�d�l: (LET ((VAR FORM) *) BODY-FORM *) ---> <OBJECT>
����: �Ǐ��ϐ����`���A���̊��Ŏ��s����(����`��)

�֐�: LET*
�d�l: (LET* ((VAR FORM) *) BODY-FORM *) ---> <OBJECT>
����: let�Ɠ��l�ł��邪�Ǐ��ϐ���������������Ƃ��낪�قȂ�(����`��)

�֐�: DYNAMIC
�d�l: (DYNAMIC VAR) ---> <OBJECT>
����: ���I�ϐ���錾����(����`��)

�֐�: SETF
�d�l: (SETF (DYNAMIC VAR) FORM) ---> <OBJECT>
����: ���I�ϐ��ɒl��������(����`��)

�֐�: DYNAMIC-LET
�d�l: (DYNAMIC-LET ((VAR FORM) *) BODY-FORM *) ---> <OBJECT>
����: ���I�ϐ��̈ꎞ�I����������(����`��)

�֐�: IF
�d�l: (IF TEST-FORM THEN-FORM ELSE-FORM+) ---> <OBJECT>
����: �����̌��ʂŕ��򂷂�(����`��)

�֐�: COND
�d�l: (COND (TEST FORM *) *) ---> <OBJECT>
����: �����̌��ʂŕ��򂷂�(����`��)

�֐�: CASE
�d�l: (CASE KEYFORM ((KEY *) FORM *) * (T FORM *) +) ---> <OBJECT>
����: keyform �̒l�ɂ���đ���ɕ��򂷂�(����`��)

�֐�: CASE-USING
�d�l: (CASE-USING PREDFORM KEYFORM ((KEY *) FORM *) * (T FORM *) +) ---> <OBJECT>
����: case ���Ƃقړ��l�ł��邪,�q��֐� predform ���r�Ɏg��(����`��)

�֐�: PROGN
�d�l: (PROGN FORM*) ---> <OBJECT>
����: �������s���s�Ȃ�(����`��)

�֐�: WHILE
�d�l: (WHILE TEST-FORM BODY-FORM *) ---> <NULL>
����: test-form �� nil �łȂ��� body-form �����s����(����`��)

�֐�: FOR
�d�l: (FOR (ITERATION-SPEC *) (END-TEST RESULT *) FORM *) ---> <OBJECT>
����: iteration-spec �Ŏ����ꂽ�����l�ƃX�e�b�p��p�� end-test �� nil �łȂ��ԌJ��Ԃ����s����(����`��)

�֐�: BLOCK
�d�l: (BLOCK NAME FORM *) ---> <OBJECT>
����: �u���b�N�^�O��t���ď������s����(����`��)

�֐�: RETURN-FROM
�d�l: (RETURN-FROM NAME RESULT-FORM) ---> TRANSFERS-CONTROL-AND-DATA
����: name �u���b�N�𔲂���(����`��)

�֐�: CATCH
�d�l: (CATCH TAG-FORM FORM *) ---> <OBJECT>
����: tag-form ���L���b�`���Aform �����s����(����`��)

�֐�: THROW
�d�l: (THROW TAG-FORM RESULT-FORM) ---> TRANSFERS-CONTROL-AND-DATA
����: tag-form ���X���[����(����`��)

�֐�: TAGBODY
�d�l: (TAGBODY TAGBODY-TAG * FORM *) ---> <OBJECT>
����: tagbody-tag��t���ď������s����(����`��)

�֐�: GO
�d�l: (GO TAGBODY-TAG) ---> TRANSFERS-CONTROL
����: tag-body�u���b�N�ɐ�����ڂ�(����`��)

�֐�: UNWIND-PROTECT
�d�l: (UNWIND-PROTECT FORM CLEANUP-FORM *) ---> <OBJECT>
����: form�̕]�����I������Ƃ��͕K�� cleanup-form �����s����(����`��)

�֐�: THE
�d�l: (THE CLASS-NAME FORM) ---> <OBJECT>
����: form �̎��s���ʂ̃N���X�� class-name �Ɛ錾����(����`��)

�֐�: ASSURE
�d�l: (ASSURE CLASS-NAME FORM) ---> <OBJECT>
����: form �̎��s���ʂ̃N���X�� class-name �Ǝ咣����A�قȂ�ꍇ�̓G���[�ƂȂ�(����`��)

�֐�: CONVERT
�d�l: (CONVERT OBJ CLASS-NAME) ---> <OBJECT>
����: obj ���N���X class-name �ɕϊ�����(����`��)

�֐�: PROBE-FILE
�d�l: (PROBE-FILE FILENAME) ---> BOOLEAN�@
����: filename �̃t�@�C�������݂��邩���`�F�b�N����

�֐�: FILE-POSITION
�d�l: (FILE-POSITION STREAM) ---> <INTEGER>
����: stream �̌��݂̃t�@�C���ʒu��Ԃ�

�֐�: SET-FILE-POSITION
�d�l: (SET-FILE-POSITION STREAM Z) ---> <INTEGER>
����:  stream �̃t�@�C���ʒu�� z �ɐݒ肷��

�֐�: FILE-LENGTH
�d�l: (FILE-LENGTH FILENAME ELEMENT-CLASS) ---> <INTEGER>
����: filename �̃t�@�C���� element-class �̃t�@�C���Ƃ��ẴT�C�Y��Ԃ�

�֐�: FUNCTIONP
�d�l: (FUNCTIONP OBJ) ---> BOOLEAN
����: obj ���֐��ł��邩���`�F�b�N����

�֐�: FUNCTION
�d�l: (FUNCTION FUNCTION-NAME) ---> <FUNCTION>
����: function-name �𖼑O�Ƃ���֐���Ԃ�(����`��)

�֐�: LAMBDA
�d�l: (LAMBDA LAMBDA-LIST FORM *) ---> <FUNCTION>
����: �����_���𐶐�����(����`��)

�֐�: LABELS
�d�l: (LABELS ((FUNCTION-NAME LAMBDA-LIST FORM *) *) BODY-FORMS *) ---> <OBJECT>
����: �Ǐ��֐��̑���������A���������i�ċA�I��`���\�j�ł���_�� flet �ƈقȂ�(����`��)

�֐�: FLET
�d�l: (FLET ((FUNCTION-NAME LAMBDA-LIST FORM *) *) BODY-FORMS *) ---> <OBJECT>
����: �Ǐ��֐��̑���������(����`��)

�֐�: APPLY
�d�l: (APPLY FUNCTION OBJ * LIST) ---> <OBJECT>
����: �֐���K�p����

�֐�: FUNCALL
�d�l: (FUNCALL FUNCTION OBJ *) ---> <OBJECT>
����: �֐����Ăяo��

�֐�: DEFCONSTANT
�d�l: (DEFCONSTANT NAME FORM) ---> <SYMBOL>
����: �萔��錾����(����`��)

�֐�: DEFGLOBAL
�d�l: (DEFGLOBAL NAME FORM) ---> <SYMBOL>
����: �L��ϐ���錾����(����`��)

�֐�: DEFDYNAMIC
�d�l: (DEFDYNAMIC NAME FORM) ---> <SYMBOL>
����: ���I�ϐ���錾����(����`��)

�֐�: DEFUN
�d�l: (DEFUN FUNCTION-NAME LAMBDA-LIST FORM *) ---> <SYMBOL>
����: �֐����`����(����`��)

�֐�: READ
�d�l: (READ INPUT-STREAM + EOS-ERROR-P + EOS-VALUE +) ---> <OBJECT>
����: input-stream ����S���Ƃ��ēǂ�

�֐�: READ-CHAR
�d�l: (READ-CHAR INPUT-STREAM + EOS-ERROR-P + EOS-VALUE +) ---> <OBJECT>
����: input-stream ����1�����ǂ�

�֐�: PREVIEW-CHAR
�d�l: (PREVIEW-CHAR INPUT-STREAM + EOS-ERROR-P + EOS-VALUE +) ---> <OBJECT>
����: ���ɓǂݍ��ޕ�����Ԃ��i1������ǂ݁B�t�@�C���|�W�V�����͕ω����Ȃ��j

�֐�: READ-LINE
�d�l: (READ-LINE INPUT-STREAM + EOS-ERROR-P + EOS-VALUE +) ---> <OBJECT>
����: 1�s�𕶎���Ƃ��ēǂ�

�֐�: STREAM-READY-P
�d�l: (STREAM-READY-P INPUT-STREAM) ---> BOOLEAN
����: �X�g���[�����ǂݍ��݉\�ɂȂ��Ă��邩

�֐�: FORMAT
�d�l: (FORMAT OUTPUT-STREAM FORMAT-STRING OBJ *) ---> <NULL>
����: format-string �ɏ]���� obj ���o�͂���

�֐�: FORMAT-CHAR
�d�l: (FORMAT-CHAR OUTPUT-STREAM CHAR) ---> <NULL>
����: 1�����o�͂���

�֐�: FORMAT-FLOAT
�d�l: (FORMAT-FLOAT OUTPUT-STREAM FLOAT) ---> <NULL>
����: ���������_���Ƃ��ďo�͂���

�֐�: FORMAT-FRESH-LINE
�d�l: (FORMAT-FRESH-LINE OUTPUT-STREAM) ---> <NULL>
����: ���s����

�֐�: FORMAT-INTEGER
�d�l: (FORMAT-INTEGER OUTPUT-STREAM INTEGER RADIX) ---> <NULL>
����: �����Ƃ��ďo�͂���

�֐�: FORMAT-OBJECT
�d�l: (FORMAT-OBJECT OUTPUT-STREAM OBJ ESCAPE-P) ---> <NULL>
����: �I�u�W�F�N�g�Ƃ��ďo�͂���

�֐�: FORMAT-TAB
�d�l: (FORMAT-TAB OUTPUT-STREAM COLUMN) ---> <NULL>
����: �^�u���o�͂���

�֐�: READ-BYTE
�d�l: (READ-BYTE INPUT-STREAM EOS-ERROR-P + EOS-VALUE +) ---> <INTEGER>
����: �o�C�g�Ƃ��ēǂ�

�֐�: WRITE-BYTE
�d�l: (WRITE-BYTE Z OUTPUT-STREAM) ---> <INTEGER>
����: �o�C�g�Ƃ��ď���

�֐�: CONSP
�d�l: (CONSP OBJ) ---> BOOLEAN
����: �R���X�����`�F�b�N����

�֐�: CONS
�d�l: (CONS OBJ1 OBJ2) ---> <CONS>
����: �R���X�𐶐�����

�֐�: CAR
�d�l: (CAR CONS) ---> <OBJECT>
����: �R���X�� Car �������o��

�֐�: CDR
�d�l: (CDR CONS) ---> <OBJECT>
����: �R���X�� Cdr �������o��

�֐�: SET-CAR
�d�l: (SET-CAR OBJ CONS) ---> <OBJECT>
����: �R���X�� Car ���ɃZ�b�g����

�֐�: SET-CDR
�d�l: (SET-CDR OBJ CONS) ---> <OBJECT>
����: �R���X�� Cdr ���ɃZ�b�g����

�֐�: NULL
�d�l: (NULL OBJ) ---> BOOLEAN
����: NULL ���`�F�b�N����

�֐�: LISTP
�d�l: (LISTP OBJ) ---> BOOLEAN
����: ���X�g���`�F�b�N����

�֐�: CREATE-LIST
�d�l: (CREATE-LIST I INITIAL-ELEMENT +) ---> <LIST>
����: ���� i �����l initial-element �̃��X�g�𐶐�����

�֐�: LIST
�d�l: (LIST OBJ *) ---> <LIST>
����: obj ��v�f�Ƃ��郊�X�g�𐶐�����

�֐�: REVERSE
�d�l: (REVERSE LIST) ---> <LIST>
����: ���X�g���t���ɂ���i���̃��X�g�͔j�󂵂Ȃ��j

�֐�: NREVERSE
�d�l: (NREVERSE LIST) ---> <LIST>
����: ���X�g���t���ɂ���i���̃��X�g�͔j�󂳂��j

�֐�: APPEND
�d�l: (APPEND LIST *) ---> <LIST>
����: ���X�g��A������

�֐�: MEMBER
�d�l: (MEMBER OBJ LIST) ---> <LIST>
����: ���X�g list �� obj ���܂܂�Ă���΁Aobj ��擪�Ƃ��镔�����X�g��Ԃ�

�֐�: MAPCAR
�d�l: (MAPCAR FUNCTION LIST +) ---> <LIST>
����: ���X�g list �̗v�f�Ɋ֐� function �����s�����ʂ̃��X�g��Ԃ�

�֐�: MAPC
�d�l: (MAPC FUNCTION LIST +) ---> <LIST>
����: ���X�g list �̗v�f�Ɋ֐� function �����s�������̃��X�g list ��Ԃ�

�֐�: MAPCAN
�d�l: (MAPCAN FUNCTION LIST +) ---> <LIST>
����: MAPCAR �̑���� list ��j�󂵂čs�Ȃ�

�֐�: MAPLIST
�d�l: (MAPLIST FUNCTION LIST +) ---> <LIST>
����: ���X�g list �̕������X�g�Ɋ֐� function �����s���A���ʂ̃��X�g��Ԃ�

�֐�: MAPL
�d�l: (MAPL FUNCTION LIST +) ---> <LIST>
����: ���X�g list �̕������X�g�Ɋ֐� function �����s���A�������X�g list ��Ԃ�

�֐�: MAPCON
�d�l: (MAPCON FUNCTION LIST +) ---> <LIST>
����: MAPLIST �̑���� list ��j�󂵂čs�Ȃ�

�֐�: ASSOC
�d�l: (ASSOC OBJ ASSOCIATION-LIST) ---> <CONS>
����: �A�z���X�g association-list �ɑ΂��� obj ���L�[�Ƃ���l��Ԃ�

�֐�: DEFMACRO
�d�l: (DEFMACRO MACRO-NAME LAMBDA-LIST FORM *) ---> <SYMBOL>
����: �}�N�����`����(����`��)

�֐�: IDENTITY
�d�l: (IDENTITY OBJ) ---> <OBJECT>�@
����: obj �����̂܂ܕԂ�

�֐�: GET-UNIVERSAL-TIME
�d�l: (GET-UNIVERSAL-TIME) ---> <INTEGER>
����: ���j�o�[�T���^�C���i�b�j��Ԃ�

�֐�: GET-INTERNAL-RUN-TIME
�d�l: (GET-INTERNAL-RUN-TIME) ---> <INTEGER>
����: ���s���Ԃ�Ԃ�

�֐�: GET-INTERNAL-REAL-TIME
�d�l: (GET-INTERNAL-REAL-TIME) ---> <INTEGER>
����: �o�ߎ��Ԃ�Ԃ�

�֐�: INTERNAL-TIME-UNITS-PER-SECOND
�d�l: (INTERNAL-TIME-UNITS-PER-SECOND) ---> <INTEGER>
����: 1�b������̃C���^�[�i���^�C���P�ʂ�Ԃ�

�֐�: NUMBERP
�d�l: (NUMBERP OBJ) ---> BOOLEAN
����: obj �����^�ł��邩���`�F�b�N����

�֐�: PARSE-NUMBER
�d�l: (PARSE-NUMBER STRING) ---> <NUMBER>
����: ������ string ����͂��Đ��^�ɕϊ�����

�֐�: =
�d�l: (= X1 X2) ---> BOOLEAN
����: ���l�������������`�F�b�N����

�֐�: /=
�d�l: (/= X1 X2) ---> BOOLEAN
����: ���l���������Ȃ������`�F�b�N����

�֐�: >=
�d�l: (>= X1 X2) ---> BOOLEAN
����: ���l x1 �� x2 �ȏ�ł��邩���`�F�b�N����

�֐�: <=
�d�l: (<= X1 X2) ---> BOOLEAN
����: ���l x1 �� x2 �ȉ��ł��邩���`�F�b�N����

�֐�: >
�d�l: (> X1 X2) ---> BOOLEAN
����: ���l x1 �� x2 ���傫�������`�F�b�N����

�֐�: <
�d�l: (< X1 X2) ---> BOOLEAN
����: ���l x1 �� x2 ��菬���������`�F�b�N����

�֐�: +
�d�l: (+ X *) ---> <NUMBER>
����: ���l�����Z����

�֐�: *
�d�l: (* X *) ---> <NUMBER>
����: ���l����Z����

�֐�: -
�d�l: (- X Y *) ---> <NUMBER>
����: ���l�����Z����

�֐�: QUOTIENT
�d�l: (QUOTIENT DIVIDEND DIVISOR +) ---> <NUMBER>
����: ���l�����Z����

�֐�: RECIPROCAL
�d�l: (RECIPROCAL X) ---> <NUMBER>
����: ���l���t���ɂ���

�֐�: MAX
�d�l: (MAX X Y *) ---> <NUMBER>
����: ���l�̍ő�l��Ԃ�

�֐�: MIN
�d�l: (MIN X Y *) ---> <NUMBER>
����: ���l�̍ŏ��l��Ԃ�

�֐�: ABS
�d�l: (ABS X) ---> <NUMBER>
����: ���l�̐�Βl��Ԃ�

�֐�: EXP
�d�l: (EXP X) ---> <NUMBER>
����: ���l�̎w���֐��̒l��Ԃ�

�֐�: LOG
�d�l: (LOG X) ---> <NUMBER>
����: ���l�̎��R�ΐ��̒l��Ԃ�

�֐�: EXPT
�d�l: (EXPT X1 X2) ---> <NUMBER>
����: ���l���ׂ��悷��

�֐�: SQRT
�d�l: (SQRT X) ---> <NUMBER>
����: ���l�̕�������Ԃ�

�֐�: SIN
�d�l: (SIN X) ---> <NUMBER>
����: ���l�� sin �֐��̒l��Ԃ�

�֐�: COS
�d�l: (COS X) ---> <NUMBER>
����: ���l�� cos �֐��̒l��Ԃ�

�֐�: TAN
�d�l: (TAN X) ---> <NUMBER>
����: ���l�� tan �֐��̒l��Ԃ�

�֐�: ATAN
�d�l: (ATAN X) ---> <NUMBER>
����: ���l�� atan �֐��̒l��Ԃ�

�֐�: ATAN2
�d�l: (ATAN2 X1 X2) ---> <NUMBER>
����: ���l�� atan2 �֐��̒l��Ԃ�

�֐�: SINH
�d�l: (SINH X) ---> <NUMBER>
����: ���l�� sinh �֐��̒l��Ԃ�

�֐�: COSH
�d�l: (COSH X) ---> <NUMBER>
����: ���l�� cosh �֐��̒l��Ԃ�

�֐�: TANH
�d�l: (TANH X) ---> <NUMBER>
����: ���l�� tanh �֐��̒l��Ԃ�

�֐�: ATANH
�d�l: (ATANH X) ---> <NUMBER>
����: ���l�� atanh �֐��̒l��Ԃ�

�֐�: FLOATP
�d�l: (FLOATP OBJ) ---> BOOLEAN
����: obj �����������_���ł��邩���`�F�b�N����

�֐�: FLOAT
�d�l: (FLOAT X) ---> <FLOAT>
����: ���^ x �𕂓������_���ɕϊ�����

�֐�: FLOOR
�d�l: (FLOOR X) ---> <INTEGER>
����: �؂艺�����s�Ȃ�

�֐�: CEILING
�d�l: (CEILING X) ---> <INTEGER>
����: �؂�グ���s�Ȃ�

�֐�: TRUNCATE
�d�l: (TRUNCATE X) ---> <INTEGER>
����: 0�����Ɋۂ߂�

�֐�: ROUND
�d�l: (ROUND X) ---> <INTEGER>
����: �l�̌ܓ����s�Ȃ�

�֐�: INTEGERP
�d�l: (INTEGERP OBJ) ---> BOOLEAN
����: obj �������ł��邩���`�F�b�N����

�֐�: DIV
�d�l: (DIV Z1 Z2) ---> <INTEGER>
����: ���l�𐮐����Z����

�֐�: MOD
�d�l: (MOD Z1 Z2) ---> <INTEGER>
����: ���l����]�v�Z����

�֐�: GCD
�d�l: (GCD Z1 Z2) ---> <INTEGER>
����: �ő���񐔂�Ԃ�

�֐�: LCM
�d�l: (LCM Z1 Z2) ---> <INTEGER>
����: �ŏ����{����Ԃ�

�֐�: ISQRT
�d�l: (ISQRT Z) ---> <INTEGER>
����: ������������Ԃ�

�֐�: DEFCLASS
�d�l: (DEFCLASS CLASS-NAME (SC-NAME *) (SLOT-SPEC *) CLASS-OPT *) ---> <SYMBOL>
����: �N���X��`���s�Ȃ�(����`��)

�֐�: GENERIC-FUNCTION-P
�d�l: (GENERIC-FUNCTION-P OBJ) ---> BOOLEAN
����: obj ����֐��ł��邩���`�F�b�N����

�֐�: DEFGENERIC
�d�l: (DEFGENERIC FUNC-SPEC LAMBDA-LIST OPTION * METHOD-DESC *) ---> <SYMBOL>
����: ��֐����`����(����`��)

�֐�: DEFMETHOD
�d�l: (DEFMETHOD FUNC-SPEC METHOD-QUALIFIER * PARAMETER-PROFILE FORM *) ---> <SYMBOL>
����: ���\�b�h�֐����`����(����`��)

�֐�: CALL-NEXT-METHOD
�d�l: (CALL-NEXT-METHOD) ---> <OBJECT>
����: �N���X�D�揇�ʂ̎��̃N���X�̃��\�b�h���Ăяo��(����`��)

�֐�: NEXT-METHOD-P
�d�l: (NEXT-METHOD-P) ---> BOOLEAN
����: ���̃��\�b�h�����݂��邩���`�F�b�N����(����`��)

�֐�: CREATE
�d�l: (CREATE CLASS INITARG * INITVAL *) ---> <OBJECT>
����: �C���X�^���X�I�u�W�F�N�g�𐶐�����(��֐�)

�֐�: INITIALIZE-OBJECT
�d�l: (INITIALIZE-OBJECT INSTANCE INITIALIZATION-LIST) ---> <OBJECT>
����: �I�u�W�F�N�g�̏��������s�Ȃ�

�֐�: CLASS-OF
�d�l: (CLASS-OF OBJ) ---> <CLASS>
����: �N���X��Ԃ�

�֐�: INSTANCEP
�d�l: (INSTANCEP OBJ CLASS) ---> BOOLEAN
����: �C���X�^���X�I�u�W�F�N�g�ł��邩���`�F�b�N����

�֐�: SUBCLASSP
�d�l: (SUBCLASSP CLASS1 CLASS2) ---> BOOLEAN
����: �T�u�N���X�ł��邩���`�F�b�N����

�֐�: CLASS
�d�l: (CLASS CLASS-NAME) ---> <CLASS>
����: ���O class-name �̃N���X��Ԃ�(����`��)

�֐�: EQ
�d�l: (EQ OBJ1 OBJ2) ---> BOOLEAN
����: obj1 �� obj2 �� eq �ł��邩���`�F�b�N����

�֐�: EQL
�d�l: (EQL OBJ1 OBJ2) ---> BOOLEAN
����: obj1 �� obj2 �� eql �ł��邩���`�F�b�N����

�֐�: EQUAL
�d�l: (EQUAL OBJ1 OBJ2) ---> BOOLEAN
����: obj1 �� obj2 �� equal �ł��邩���`�F�b�N����

�֐�: NOT
�d�l: (NOT OBJ) ---> BOOLEAN
����: obj �̔ے��Ԃ�

�֐�: AND
�d�l: (AND FORM *) ---> <OBJECT>
����: form �� AND ������(����`��)

�֐�: OR
�d�l: (OR FORM *) ---> <OBJECT>
����: form �� OR ������(����`��)

�֐�: LENGTH
�d�l: (LENGTH SEQUENCE) ---> <INTEGER>
����: �� sequence �̒�����Ԃ�

�֐�: ELT
�d�l: (ELT SEQUENCE Z) ---> <OBJECT>
����: �� sequence �� z �Ԗڂ̗v�f��Ԃ�

�֐�: SET-ELT
�d�l: (SET-ELT OBJ SEQUENCE Z) ---> <OBJECT>
����: �� sequence �� z �Ԗڂ� obj ���Z�b�g����

�֐�: SUBSEQ
�d�l: (SUBSEQ SEQUENCE Z1 Z2) ---> SEQUENCE
����: �� sequence �� z1 �Ԗڂ��� z2 �Ԗڂ̕���������o��

�֐�: MAP-INTO
�d�l: (MAP-INTO DESTINATION FUNCTION SEQ *) ---> SEQUENCE
����: �� sequence �̗v�f�Ɋ֐� function ��K�p���āA���̌��ʂ�� destination �Ɋi�[����

�֐�: STREAMP
�d�l: (STREAMP OBJ) ---> BOOLEAN
����: obj ���X�g���[���ł��邩���`�F�b�N����

�֐�: OPEN-STREAM-P
�d�l: (OPEN-STREAM-P OBJ) ---> BOOLEAN
����: obj ���I�[�v�����ꂽ�X�g���[���ł��邩���`�F�b�N����

�֐�: INPUT-STREAM-P
�d�l: (INPUT-STREAM-P OBJ) ---> BOOLEAN
����: obj �����̓X�g���[���ł��邩���`�F�b�N����

�֐�: OUTPUT-STREAM-P
�d�l: (OUTPUT-STREAM-P OBJ) ---> BOOLEAN
����: obj ���o�̓X�g���[���ł��邩���`�F�b�N����

�֐�: STANDARD-INPUT
�d�l: (STANDARD-INPUT) ---> <STREAM>
����: �W�����͂�Ԃ�

�֐�: STANDARD-OUTPUT
�d�l: (STANDARD-OUTPUT) ---> <STREAM>
����: �W���o�͂�Ԃ�

�֐�: ERROR-OUTPUT
�d�l: (ERROR-OUTPUT) ---> <STREAM>
����: �G���[�o�͂�Ԃ�

�֐�: WITH-STANDARD-INPUT
�d�l: (WITH-STANDARD-INPUT STREAM-FORM FORM *) ---> <OBJECT>
����: �W�����͂� stream-form �̎��s���ʂɂ��� form �����s����(����`��)

�֐�: WITH-STANDARD-OUTPUT
�d�l: (WITH-STANDARD-OUTPUT STREAM-FORM FORM *) ---> <OBJECT>
����: �W���o�͂� stream-form �̎��s���ʂɂ��� form �����s����(����`��)

�֐�: WITH-ERROR-OUTPUT
�d�l: (WITH-ERROR-OUTPUT STREAM-FORM FORM *) ---> <OBJECT>
����: �G���[�o�͂� stream-form �̎��s���ʂɂ��� form �����s����(����`��)

�֐�: OPEN-INPUT-FILE
�d�l: (OPEN-INPUT-FILE FILENAME ELEMENT-CLASS +) ---> <STREAM>
����: �t�@�C���� filename �̃t�@�C������̓X�g���[���Ƃ��ăI�[�v������

�֐�: OPEN-OUTPUT-FILE
�d�l: (OPEN-OUTPUT-FILE FILENAME ELEMENT-CLASS +) ---> <STREAM>
����: �t�@�C���� filename �̃t�@�C�����o�̓X�g���[���Ƃ��ăI�[�v������

�֐�: OPEN-IO-FILE
�d�l: (OPEN-IO-FILE FILENAME ELEMENT-CLASS +) ---> <STREAM>
����: �t�@�C���� filename �̃t�@�C������o�̓X�g���[���Ƃ��ăI�[�v������

�֐�: WITH-OPEN-INPUT-FILE
�d�l: (WITH-OPEN-INPUT-FILE (NAME FILE ELEMENT-CLASS +) FORM *) ---> <OBJECT>
����: �t�@�C���� file �̃t�@�C������̓X�g���[���Ƃ��ăI�[�v������ form �����s���A���s��N���[�Y����i����`���j

�֐�: WITH-OPEN-OUTPUT-FILE
�d�l: (WITH-OPEN-OUTPUT-FILE (NAME FILE ELEMENT-CLASS +) FORM *) ---> <OBJECT>
����: �t�@�C���� file �̃t�@�C�����o�̓X�g���[���Ƃ��ăI�[�v������ form �����s���A���s��N���[�Y����i����`���j

�֐�: WITH-OPEN-IO-FILE
�d�l: (WITH-OPEN-IO-FILE (NAME FILE ELEMENT-CLASS +) FORM *) ---> <OBJECT>
����: �t�@�C���� file �̃t�@�C������o�̓X�g���[���Ƃ��ăI�[�v������ form �����s���A���s��N���[�Y����i����`���j

�֐�: CLOSE
�d�l: (CLOSE STREAM) ---> IMPLEMENTATION-DEFINED
����: �X�g���[�����N���[�Y����

�֐�: CREATE-STRING-INPUT-STREAM
�d�l: (CREATE-STRING-INPUT-STREAM STRING) ---> <STREAM>
����: ���͂̕�����X�g���[���𐶐�����

�֐�: CREATE-STRING-OUTPUT-STREAM
�d�l: (CREATE-STRING-OUTPUT-STREAM) ---> <STREAM>
����: �o�͂̕�����X�g���[���𐶐�����

�֐�: GET-OUTPUT-STREAM-STRING
�d�l: (GET-OUTPUT-STREAM-STRING STREAM) ---> <STRING>
����: �o�̓X�g���[���ɏo�͂��ꂽ�������Ԃ�

�֐�: STRINGP
�d�l: (STRINGP OBJ) ---> BOOLEAN
����: obj ��������ł��邩���`�F�b�N����

�֐�: CREATE-STRING
�d�l: (CREATE-STRING I INITIAL-ELEMENT+) ---> <STRING>
����: ���� i �����l initial-element �̕�����𐶐�����

�֐�: STRING=
�d�l: (STRING= STRING1 STRING2) ---> QUASI-BOOLEAN
����: �����񂪓����������`�F�b�N����

�֐�: STRING/=
�d�l: (STRING/= STRING1 STRING2) ---> QUASI-BOOLEAN
����: �����񂪓������Ȃ������`�F�b�N����

�֐�: STRING<
�d�l: (STRING< STRING1 STRING2) ---> QUASI-BOOLEAN
����: ������ sting1 �� string2 ���������������`�F�b�N����

�֐�: STRING>
�d�l: (STRING> STRING1 STRING2) ---> QUASI-BOOLEAN
����: ������ sting1 �� string2 �����傫�������`�F�b�N����

�֐�: STRING>=
�d�l: (STRING>= STRING1 STRING2) ---> QUASI-BOOLEAN
����: ������ sting1 �� string2 �ȉ������`�F�b�N����

�֐�: STRING<=
�d�l: (STRING<= STRING1 STRING2) ---> QUASI-BOOLEAN
����: ������ sting1 �� string2 �ȏォ���`�F�b�N����

�֐�: CHAR-INDEX
�d�l: (CHAR-INDEX CHARACTER STRING START-POSITION +) ---> <OBJECT>
����: ������ string ���ɕ��� character �������ʒu��Ԃ�

�֐�: STRING-INDEX
�d�l: (STRING-INDEX SUBSTRING STRING START-POSITION +) ---> <OBJECT>
����: ������ string �ɕ��������� substring �������ʒu��Ԃ�

�֐�: STRING-APPEND
�d�l: (STRING-APPEND STRING *) ---> <STRING>
����: �������A������

�֐�: SYMBOLP
�d�l: (SYMBOLP OBJ) ---> BOOLEAN
����: �V���{�����`�F�b�N����

�֐�: PROPERTY
�d�l: (PROPERTY SYMBOL PROPERTY-NAME OBJ +) ---> <OBJECT>
����: �V���{���̃v���p�e�B�����o��

�֐�: SET-PROPERTY
�d�l: (SET-PROPERTY OBJ SYMBOL PROPERTY-NAME) ---> <OBJECT>
����: �V���{���Ƀv���p�e�B���Z�b�g����

�֐�: REMOVE-PROPERTY
�d�l: (REMOVE-PROPERTY SYMBOL PROPERTY-NAME) ---> <OBJECT>
����: �V���{������v���p�e�B���폜����

�֐�: GENSYM
�d�l: (GENSYM) ---> <SYMBOL>
����: ���O�Ȃ��V���{���𐶐�����

�֐�: BASIC-VECTOR-P
�d�l: (BASIC-VECTOR-P OBJ) ---> BOOLEAN
����: BASIC �x�N�^���`�F�b�N����

�֐�: GENERAL-VECTOR-P
�d�l: (GENERAL-VECTOR-P OBJ) ---> BOOLEAN
����: GENERIC VECTOR���`�F�b�N����

�֐�: CREATE-VECTOR
�d�l: (CREATE-VECTOR I INITIAL-ELEMENT +) ---> <GENERAL-VECTOR>
����: �v�f�� i �����l initial-element �̃x�N�^�𐶐�����

�֐�: VECTOR
�d�l: (VECTOR OBJ *) ---> <GENERAL-VECTOR>
����: obj ... ��v�f�Ƃ���x�N�^�𐶐�����

�֐�: LOAD
�d�l: (LOAD FILE) ---> T
����: �t�@�C�� file �����[�h����i�g���j

�֐�: TIME
�d�l: (TIME FORM) ---> <OBJECT>
����: �t�H�[�� form �����s���o�ߎ��Ԃ�\������i����`���j�i�g���j


�֐�: EVAL
�d�l: (EVAL FORM) ---> <OBJECT>
����: �t�H�[�� form ��]������i�g���j


�֐�: COMPILE-FILE
�d�l: (COMPILE-FILE FILE) ---> BOOLEAN
����: �t�@�C�� file ���R���p�C������(�g��)


�֐�: GBC
�d�l: (GBC) ---> <NULL>
����: gc �������I�Ɏ��s���� (�g��)

�֐�: PRINT
�d�l: (PRINT OBJECT) ---> <NULL>
����: object �� stream �ɕ\������(�g��)

�֐�: QUIT
�d�l: (QUIT) ---> TRANSFERS-CONTROL
����: ISLisp�����n���I������(�g��)

```
