import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gh6_ucap/services/gemini_service.dart';
import 'package:gh6_ucap/services/profile_service.dart';
import 'package:gh6_ucap/services/user_preferences.dart';

// DATA MODEL UNTUK MEMUDAHKAN
class ScenarioStep {
  final String story;
  final String characterEmoji;
  final Alignment characterAlignment;
  final List<ScenarioChoice>? choices;
  ScenarioStep({
    required this.story,
    required this.characterEmoji,
    required this.characterAlignment,
    this.choices,
  });
}

class ScenarioChoice {
  final String text;
  final String emoji;
  final bool isCorrect;
  final String feedback;
  final String reason;
  ScenarioChoice({
    required this.text,
    required this.emoji,
    required this.isCorrect,
    required this.feedback,
    required this.reason,
  });
}

class ScenarioScreen extends StatefulWidget {
  final String scenarioTitle;
  final String category;

  const ScenarioScreen({
    super.key,
    required this.scenarioTitle,
    required this.category,
  });

  @override
  _ScenarioScreenState createState() => _ScenarioScreenState();
}

class _ScenarioScreenState extends State<ScenarioScreen>
    with TickerProviderStateMixin {
  @override
  // Animation Controllers
  late AnimationController _characterController;
  late AnimationController _bubbleController;
  late AnimationController _floatingController;
  late AnimationController _feedbackCardController;
  late AnimationController _heartController;
  late AnimationController _reasonDialogController;
  late AnimationController _retryController;
  final ProfileService _profileService = ProfileService();

  // State Management
  int currentStepIndex = 0;
  int lives = 3;
  bool showChoices = false;
  bool showFeedback = false;
  bool showReasonDialog = false;
  bool needsRetry = false;
  String currentStoryText = '';
  ScenarioChoice? selectedChoice;
  String _userReason = '';
  Timer? _textTimer;
  List<int> incorrectChoices = [];
  final GeminiService _geminiService = GeminiService();
  bool _isGeneratingFeedback = false;
  String? _aiFeedback;

  // Data
  late List<ScenarioStep> scenarioSteps;

  @override
  void initState() {
    super.initState();

    // Check if player can play (24-hour cooldown)
    if (!_canPlayGame()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCooldownDialog();
      });
      return;
    }

    _initializeData();
    _initializeAnimations();
    _startCurrentStep();
  }

  void _showCooldownDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          '⏰ Masih Cooldown',
          style: TextStyle(fontSize: 20.sp, color: Colors.orange),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer, size: 64.w, color: Colors.orange),
            SizedBox(height: 16.h),
            Text(
              'Nyawa masih dalam proses regenerasi.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              'Silakan kembali 24 jam setelah game over terakhir.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Kembali ke Menu'),
            ),
          ),
        ],
      ),
    );
  }

  void _initializeData() {
    switch (widget.scenarioTitle) {
      case 'Wawancara Kerja':
        _loadInterviewScenario();
        break;
      case 'Negosiasi Gaji':
        _loadSalaryNegotiationScenario();
        break;
      case 'Budgeting Bulanan':
        _loadBudgetingScenario();
        break;
      case 'Menghadapi Diskriminasi':
        _loadDiscriminationScenario();
        break;
      case 'Mencari Tempat Tinggal':
        _loadHousingScenario();
        break;
      default:
        _loadDefaultScenario();
    }
  }

  void _loadInterviewScenario() {
    scenarioSteps = [
      ScenarioStep(
        story:
            'Kamu duduk di ruang tunggu sebuah startup teknologi yang keren. Tanganmu sedikit berkeringat, jantung berdebar kencang. Ini adalah momen yang sudah kamu persiapkan berbulan-bulan!',
        characterEmoji: '😰',
        characterAlignment: Alignment.center,
      ),
      ScenarioStep(
        story:
            'Pintu terbuka dan seorang wanita muda muncul dengan senyum ramah. "Hai! Kamu pasti Andi ya? Aku Sarah, HR Manager di sini. Siap untuk ngobrol santai?"',
        characterEmoji: '😊',
        characterAlignment: Alignment.centerRight,
      ),
      ScenarioStep(
        story:
            'Di ruang meeting yang nyaman, Sarah bertanya dengan antusias, "Jadi Andi, ceritakan dong tentang dirimu dan kenapa kamu tertarik join keluarga besar kami di sini?"',
        characterEmoji: '🤔',
        characterAlignment: Alignment.centerRight,
        choices: [
          ScenarioChoice(
            text:
                'Langsung cerita tentang nilai IPK tinggi dan prestasi akademis',
            emoji: '🎓',
            isCorrect: false,
            feedback:
                'Sarah terlihat kurang antusias. Dia lebih tertarik pada passion dan motivasimu.',
            reason:
                'Pewawancara ingin melihat kepribadian dan kecocokan budaya, bukan hanya angka. Tunjukkan motivasi dan antusiasmemu!',
          ),
          ScenarioChoice(
            text:
                'Bercerita tentang passion, lalu hubungkan dengan visi perusahaan',
            emoji: '✨',
            isCorrect: true,
            feedback:
                'Sempurna! Mata Sarah berbinar-binar. Kamu menunjukkan riset yang mendalam dan minat yang tulus.',
            reason:
                'Ini menunjukkan kamu proaktif dan benar-benar tertarik pada perusahaan, bukan sekadar mencari pekerjaan sembarangan.',
          ),
          ScenarioChoice(
            text:
                'Cerita panjang tentang hobi gaming dan kehidupan sehari-hari',
            emoji: '🎮',
            isCorrect: false,
            feedback:
                'Sarah terlihat bingung menghubungkan ceritamu dengan posisi pekerjaan.',
            reason:
                'Meskipun kepribadian itu penting, tetap fokus pada hal-hal yang relevan dengan pekerjaan yang kamu lamar.',
          ),
        ],
      ),
      ScenarioStep(
        story:
            'Sarah melanjutkan, "Tell me about a time when you faced a challenging situation and how you handled it." Kamu ingat beberapa situasi sulit yang pernah kamu alami.',
        characterEmoji: '🧐',
        characterAlignment: Alignment.centerRight,
        choices: [
          ScenarioChoice(
            text: 'Cerita tentang tugas kuliah yang deadline-nya mepet',
            emoji: '📚',
            isCorrect: false,
            feedback:
                'Sarah mengangguk biasa saja. Sepertinya dia ingin contoh yang lebih menantang.',
            reason:
                'Contoh dari dunia kerja atau organisasi akan lebih kuat daripada tugas kuliah biasa.',
          ),
          ScenarioChoice(
            text:
                'Menceritakan konflik dalam tim organisasi dan cara menyelesaikannya',
            emoji: '🤝',
            isCorrect: true,
            feedback:
                'Sarah menunjukkan ketertarikan! Dia menyukai bagaimana kamu menangani konflik interpersonal.',
            reason:
                'Soft skills seperti conflict resolution sangat dihargai di dunia kerja. Ini menunjukkan kematangan emosional.',
          ),
          ScenarioChoice(
            text: 'Bercerita tentang masalah keluarga yang rumit',
            emoji: '👨‍👩‍👧‍👦',
            isCorrect: false,
            feedback:
                'Sarah terlihat sedikit canggung. Topik pribadi seperti ini terlalu personal untuk wawancara.',
            reason:
                'Wawancara kerja bukan tempat untuk sharing masalah pribadi. Fokuslah pada pengalaman profesional atau akademis.',
          ),
        ],
      ),
      ScenarioStep(
        story:
            '"Sekarang, do you have any questions for us?" tanya Sarah sambil tersenyum. Ini adalah kesempatan emas untuk menunjukkan ketertarikanmu!',
        characterEmoji: '❓',
        characterAlignment: Alignment.centerRight,
        choices: [
          ScenarioChoice(
            text: '"Tidak ada pertanyaan, saya sudah cukup paham."',
            emoji: '🙅‍♂️',
            isCorrect: false,
            feedback:
                'Sarah terlihat kecewa. Tidak bertanya bisa menunjukkan kurangnya interest.',
            reason:
                'Tidak bertanya adalah red flag! Itu menunjukkan kamu tidak curious atau tidak serius dengan posisi ini.',
          ),
          ScenarioChoice(
            text:
                '"Bagaimana culture kerja di sini? Dan apa growth opportunity-nya?"',
            emoji: '🚀',
            isCorrect: true,
            feedback:
                'Sarah terlihat senang! Pertanyaan ini menunjukkan kamu berpikir jangka panjang.',
            reason:
                'Pertanyaan tentang budaya kerja dan pengembangan karir menunjukkan kamu serius dan ingin berkembang bersama perusahaan.',
          ),
          ScenarioChoice(
            text: '"Kapan saya bisa mulai kerja dan berapa gaji starting-nya?"',
            emoji: '💰',
            isCorrect: false,
            feedback:
                'Sarah tersenyum kaku. Menanyakan gaji di interview pertama bisa terkesan greedy.',
            reason:
                'Terlalu dini membahas gaji. Fokus dulu pada value yang bisa kamu berikan, baru kemudian kompensasi.',
          ),
        ],
      ),
      ScenarioStep(
        story:
            'Sarah berdiri dan mengulurkan tangan dengan senyum lebar. "Thank you banget Andi! It was really great talking with you. HR team akan follow up dalam 2-3 hari ya. Have a wonderful day!"',
        characterEmoji: '🤝',
        characterAlignment: Alignment.center,
      ),
    ];
  }

  void _loadSalaryNegotiationScenario() {
    scenarioSteps = [
      ScenarioStep(
        story:
            'Setelah 6 bulan bekerja di startup teknologi, kamu merasa kontribusimu sudah signifikan. Tim makin bergantung padamu, dan kamu sering lembur. Saatnya berbicara dengan boss tentang kenaikan gaji.',
        characterEmoji: '💪',
        characterAlignment: Alignment.center,
      ),
      ScenarioStep(
        story:
            'Kamu masuk ke ruangan pak Budi, CEO-mu yang friendly tapi tegas. "Andi! Gimana kabarnya? Ada yang mau dibicarakan?" tanyanya sambil tersenyum.',
        characterEmoji: '😄',
        characterAlignment: Alignment.centerRight,
      ),
      ScenarioStep(
        story:
            'Setelah small talk sebentar, pak Budi bertanya, "So, what\'s on your mind?" Ini saatnya kamu menyampaikan maksudmu dengan cara yang tepat.',
        characterEmoji: '🤔',
        characterAlignment: Alignment.centerRight,
        choices: [
          ScenarioChoice(
            text:
                '"Pak, saya merasa gaji saya masih kecil dibanding teman-teman saya."',
            emoji: '😔',
            isCorrect: false,
            feedback:
                'Pak Budi mengerutkan dahi. Membandingkan dengan orang lain terkesan tidak profesional.',
            reason:
                'Jangan pernah membandingkan dengan orang lain. Fokus pada value dan kontribusi yang kamu berikan ke perusahaan.',
          ),
          ScenarioChoice(
            text:
                '"Pak, berdasarkan kontribusi dan pencapaian saya selama 6 bulan ini, saya ingin mendiskusikan adjustment gaji."',
            emoji: '📊',
            isCorrect: true,
            feedback:
                'Pak Budi mengangguk dan terlihat tertarik. Pendekatan yang data-driven ini profesional.',
            reason:
                'Approach yang tepat! Fokus pada achievement dan value yang sudah kamu berikan, bukan pada kebutuhan pribadi.',
          ),
          ScenarioChoice(
            text:
                '"Pak, biaya hidup sekarang mahal banget, saya butuh kenaikan gaji."',
            emoji: '💸',
            isCorrect: false,
            feedback:
                'Pak Budi terlihat kurang antusias. Personal financial problem bukan alasan kuat untuk raise.',
            reason:
                'Masalah keuangan pribadi bukan tanggung jawab perusahaan. Perusahaan membayar berdasarkan value, bukan need.',
          ),
        ],
      ),
      ScenarioStep(
        story:
            '"Oke, coba jelasin achievements kamu selama ini," kata pak Budi sambil membuka laptop. Kamu harus menyampaikan data yang convincing.',
        characterEmoji: '💻',
        characterAlignment: Alignment.centerRight,
        choices: [
          ScenarioChoice(
            text:
                'Menyebutkan bahwa kamu selalu datang tepat waktu dan jarang sakit',
            emoji: '⏰',
            isCorrect: false,
            feedback:
                'Pak Budi tersenyum tipis. Itu basic requirement, bukan achievement.',
            reason:
                'Datang tepat waktu itu basic expectation, bukan achievement. Fokus pada hasil kerja yang measurable.',
          ),
          ScenarioChoice(
            text:
                'Menyampaikan data konkret: 3 project selesai ahead of schedule, client satisfaction 95%',
            emoji: '📈',
            isCorrect: true,
            feedback:
                'Mata pak Budi berbinar! Data konkret ini sangat convincing dan professional.',
            reason:
                'Data yang konkret dan measurable adalah amunisi terkuat dalam negosiasi gaji. Numbers don\'t lie!',
          ),
          ScenarioChoice(
            text:
                'Bercerita panjang lebar tentang betapa keras usahamu setiap hari',
            emoji: '😤',
            isCorrect: false,
            feedback:
                'Pak Budi mengangguk sopan tapi terlihat bosan. Hard work tanpa result tidak impressive.',
            reason:
                'Effort itu penting, tapi yang lebih penting adalah hasil. Tunjukkan impact dari hard work-mu.',
          ),
        ],
      ),
      ScenarioStep(
        story:
            'Pak Budi mengangguk terkesan, "Impressive! Berapa range yang kamu harapkan?" Moment crucial ini menentukan segalanya.',
        characterEmoji: '💰',
        characterAlignment: Alignment.centerRight,
        choices: [
          ScenarioChoice(
            text: '"Saya serahkan sepenuhnya ke Bapak untuk menentukan."',
            emoji: '🤷‍♂️',
            isCorrect: false,
            feedback:
                'Pak Budi terlihat bingung. Kamu terkesan tidak punya preparation dan confidence.',
            reason:
                'Jangan terlalu passive! Kamu harus punya research dan ekspektasi yang jelas sebelum negosiasi.',
          ),
          ScenarioChoice(
            text:
                '"Berdasarkan market rate dan kontribusi saya, saya mengharapkan range 8-10 juta."',
            emoji: '🎯',
            isCorrect: true,
            feedback:
                'Pak Budi mengangguk dan mulai menghitung. Range yang specific dan well-researched!',
            reason:
                'Perfect! Kamu punya data market rate dan menyampaikan range yang reasonable berdasarkan riset.',
          ),
          ScenarioChoice(
            text: '"Saya mau gaji naik 50% dari sekarang, pak!"',
            emoji: '🚀',
            isCorrect: false,
            feedback:
                'Pak Budi tersentak kaget. Angka 50% terlalu agresif dan tidak realistic.',
            reason:
                'Terlalu agresif! Kenaikan yang tidak realistic bisa merusak negosiasi. Biasanya 10-20% adalah range normal.',
          ),
        ],
      ),
      ScenarioStep(
        story:
            'Pak Budi tersenyum, "Oke Andi, gue appreciate your contribution. Let me discuss this with the team dulu ya. I\'ll get back to you next week dengan good news!"',
        characterEmoji: '👍',
        characterAlignment: Alignment.center,
      ),
    ];
  }

  void _loadBudgetingScenario() {
    scenarioSteps = [
      ScenarioStep(
        story:
            'Akhir bulan lagi, dan kamu menatap saldo rekening yang menipis. Padahal baru tanggal 25! "Kemana aja uang gue pergi sih?" gumammu sambil scrolling mobile banking.',
        characterEmoji: '😅',
        characterAlignment: Alignment.center,
      ),
      ScenarioStep(
        story:
            'Kamu memutuskan untuk serius mengatur keuangan. Gaji bulanan kamu 5 juta. Sekarang saatnya bikin budget plan yang realistic!',
        characterEmoji: '📋',
        characterAlignment: Alignment.center,
      ),
      ScenarioStep(
        story:
            'Prioritas pertama: pengeluaran wajib. Kamu harus allocation budget untuk kebutuhan pokok dulu sebelum yang lain.',
        characterEmoji: '🏠',
        characterAlignment: Alignment.center,
        choices: [
          ScenarioChoice(
            text: 'Alokasi 70% untuk kebutuhan pokok (makan, transport, dll)',
            emoji: '🍚',
            isCorrect: false,
            feedback:
                '70% terlalu besar untuk kebutuhan pokok. Kamu jadi tidak punya ruang untuk saving dan investasi.',
            reason:
                'Rule of thumb: 50% untuk needs, 30% untuk wants, 20% untuk saving/investasi. Jangan sampai lifestyle inflation menghabiskan semua income.',
          ),
          ScenarioChoice(
            text:
                'Alokasi 50% untuk kebutuhan pokok, 30% lifestyle, 20% saving',
            emoji: '💰',
            isCorrect: true,
            feedback:
                'Perfect! Ini mengikuti aturan 50-30-20 yang sustainable dan sehat untuk keuangan jangka panjang.',
            reason:
                'Aturan 50-30-20 adalah golden rule budgeting! 50% needs, 30% wants, 20% savings and investments.',
          ),
          ScenarioChoice(
            text:
                'Alokasi 30% untuk kebutuhan pokok, sisanya untuk lifestyle dan hobi',
            emoji: '🎉',
            isCorrect: false,
            feedback:
                'Terlalu optimis! 30% tidak realistic untuk cover semua kebutuhan pokok di Indonesia.',
            reason:
                'Unrealistic! Di Indonesia, kebutuhan pokok minimal 40-50% dari income. Planning yang tidak realistic akan gagal dijalankan.',
          ),
        ],
      ),
      ScenarioStep(
        story:
            'Kamu mulai tracking pengeluaran harian. Ternyata coffee shop visits kamu itu 15rb x 20 hari = 300rb per bulan! "Astaga, segitu ya?"',
        characterEmoji: '☕',
        characterAlignment: Alignment.center,
        choices: [
          ScenarioChoice(
            text: 'Langsung stop total ke coffee shop mulai besok',
            emoji: '🚫',
            isCorrect: false,
            feedback:
                'Terlalu ekstrem! Perubahan mendadak biasanya tidak sustainable dan bikin stress.',
            reason:
                'Perubahan drastis sulit dipertahankan. Better gradual changes yang sustainable daripada shock therapy yang bikin rebound.',
          ),
          ScenarioChoice(
            text:
                'Tetap ke coffee shop tapi cuma 2x seminggu, sisanya bikin kopi sendiri',
            emoji: '⚖️',
            isCorrect: true,
            feedback:
                'Smart choice! Balanced approach yang tetap mempertahankan small pleasure tapi controlled.',
            reason:
                'Balanced approach is the best! Tetap bisa enjoy hidup tapi dengan kontrol. Sustainable dan tidak bikin depresi.',
          ),
          ScenarioChoice(
            text: 'Biarin aja, hidup cuma sekali, coffee shop is life!',
            emoji: '🤪',
            isCorrect: false,
            feedback:
                'YOLO mindset bahaya untuk keuangan! Kamu akan terus stuck di cycle ini selamanya.',
            reason:
                'YOLO mindset adalah financial suicide! Small things like this yang accumulate jadi big financial problems.',
          ),
        ],
      ),
      ScenarioStep(
        story:
            'Setelah 3 bulan konsisten, kamu berhasil save 1 juta per bulan! Sekarang uang saving ini mau diapain?',
        characterEmoji: '💎',
        characterAlignment: Alignment.center,
        choices: [
          ScenarioChoice(
            text: 'Ditaruh di tabungan biasa aja, aman dan tidak ribet',
            emoji: '🏦',
            isCorrect: false,
            feedback:
                'Inflation akan menggerus value uangmu! Tabungan biasa return-nya kalah sama inflasi.',
            reason:
                'Tabungan biasa itu untuk emergency fund, bukan untuk long-term wealth building. Inflasi akan menggerus purchasing power.',
          ),
          ScenarioChoice(
            text:
                'Diversifikasi: 60% reksa dana, 30% deposito, 10% emergency fund',
            emoji: '📊',
            isCorrect: true,
            feedback:
                'Excellent financial planning! Diversifikasi yang smart untuk different time horizons.',
            reason:
                'Diversifikasi adalah kunci! Different instruments untuk different goals. Emergency fund liquid, reksa dana untuk growth.',
          ),
          ScenarioChoice(
            text: 'All-in crypto dan saham meme, biar cepat kaya!',
            emoji: '🚀',
            isCorrect: false,
            feedback:
                'Terlalu berisiko! Bisa-bisa saving 3 bulan hilang dalam sehari.',
            reason:
                'High risk without proper knowledge adalah gambling, bukan investing! Start with safer instruments dulu sambil belajar.',
          ),
        ],
      ),
      ScenarioStep(
        story:
            'Setahun kemudian, financial habit kamu sudah solid. Emergency fund 6 bulan, investasi rutin, dan lifestyle tetap enjoyable. "Financial freedom, here I come!" senyummu puas.',
        characterEmoji: '🏆',
        characterAlignment: Alignment.center,
      ),
    ];
  }

  void _loadDiscriminationScenario() {
    scenarioSteps = [
      ScenarioStep(
        story:
            'Di kantor, kamu mendengar rekan kerja Alex membuat jokes yang menyinggung tentang background etnismu. Beberapa teman terlihat uncomfortable, tapi tidak ada yang speak up.',
        characterEmoji: '😔',
        characterAlignment: Alignment.center,
      ),
      ScenarioStep(
        story:
            'Alex mengulangi joke-nya lagi, kali ini lebih keras dan beberapa orang tertawa. Kamu merasa tersinggung dan perlu mengambil action.',
        characterEmoji: '😤',
        characterAlignment: Alignment.centerLeft,
      ),
      ScenarioStep(
        story:
            'Kamu harus memutuskan bagaimana merespon situasi ini dengan tepat. Pilihan yang kamu ambil akan mempengaruhi workplace dynamics.',
        characterEmoji: '🤔',
        characterAlignment: Alignment.center,
        choices: [
          ScenarioChoice(
            text: 'Diam saja dan pura-pura tidak mendengar',
            emoji: '🙈',
            isCorrect: false,
            feedback:
                'Dengan diam, kamu membiarkan behavior toxic ini continue dan makin normalize.',
            reason:
                'Silence is compliance. Discrimination akan terus berlanjut jika tidak ada yang speak up. Kamu punya hak untuk workplace yang respectful.',
          ),
          ScenarioChoice(
            text: 'Langsung confront Alex dengan marah di depan semua orang',
            emoji: '😡',
            isCorrect: false,
            feedback:
                'Konfrontasi emosional bisa backfire dan malah bikin kamu terlihat unprofessional.',
            reason:
                'Emotional outburst bisa merusak reputation kamu. Better approach yang calm dan professional untuk hasil yang lebih efektif.',
          ),
          ScenarioChoice(
            text:
                'Bicara dengan Alex secara private dulu untuk clarify dan educate',
            emoji: '🗣️',
            isCorrect: true,
            feedback:
                'Good approach! Giving Alex chance untuk understand dan learn tanpa public humiliation.',
            reason:
                'Private conversation adalah first step yang bijak. Memberi kesempatan untuk misunderstanding dan genuine learning.',
          ),
        ],
      ),
      ScenarioStep(
        story:
            'Kamu approach Alex setelah meeting. "Hey Alex, bisa ngobrol sebentar? Tadi joke kamu agak menyinggung sih..." katamu dengan calm tone.',
        characterEmoji: '💬',
        characterAlignment: Alignment.centerRight,
      ),
      ScenarioStep(
        story:
            'Alex terlihat surprised, "Oh sorry bro, gue cuma bercanda kok. Lo sensitif banget deh!" How do you respond to this dismissive reaction?',
        characterEmoji: '🤷‍♂️',
        characterAlignment: Alignment.centerLeft,
        choices: [
          ScenarioChoice(
            text: '"Iya deh, mungkin gue yang terlalu sensitif. Sorry ya."',
            emoji: '😞',
            isCorrect: false,
            feedback:
                'Jangan gaslight diri sendiri! Valid feelings kamu tidak boleh di-dismiss sebagai "sensitif".',
            reason:
                'Jangan let others invalidate your feelings. Discrimination disguised as "joke" tetap discrimination. You have the right to feel respected.',
          ),
          ScenarioChoice(
            text:
                '"Alex, intent vs impact itu beda. Meskipun lo cuma bercanda, impact-nya tetap menyakitkan."',
            emoji: '🎯',
            isCorrect: true,
            feedback:
                'Perfect explanation! Kamu educate Alex tentang impact without attacking his character.',
            reason:
                'Brilliant! Menjelaskan concept intent vs impact adalah cara powerful untuk educate without being confrontational.',
          ),
          ScenarioChoice(
            text: '"Lo racist Alex! Gue bakal report ke HR sekarang juga!"',
            emoji: '⚡',
            isCorrect: false,
            feedback:
                'Terlalu escalate! Alex jadi defensive dan lost opportunity untuk genuine learning.',
            reason:
                'Jumping to labels dan threats bisa backfire. Better give chance untuk education dulu before formal reporting.',
          ),
        ],
      ),
      ScenarioStep(
        story:
            'Alex mulai understand, "Oh gitu ya... Gue nggak kepikiran sih. Sorry deh, gue akan lebih hati-hati." Progress yang baik, tapi kamu perlu memastikan ini sustainable.',
        characterEmoji: '😌',
        characterAlignment: Alignment.centerLeft,
        choices: [
          ScenarioChoice(
            text:
                '"Okay, thank you Alex. Cukup sekali ini aja ya discussion-nya."',
            emoji: '✅',
            isCorrect: false,
            feedback:
                'One-time conversation mungkin tidak cukup untuk lasting change. Perlu follow-up.',
            reason:
                'Behavior change butuh time dan reinforcement. Better keep communication open untuk ensure lasting change.',
          ),
          ScenarioChoice(
            text:
                '"Thanks Alex! Kalau ada yang kurang clear, feel free to ask ya. Let\'s create inclusive environment together."',
            emoji: '🤝',
            isCorrect: true,
            feedback:
                'Excellent! Kamu build partnership untuk positive change, bukan just one-time correction.',
            reason:
                'Collaborative approach untuk long-term change! Building allyship dan open communication untuk sustainable improvement.',
          ),
          ScenarioChoice(
            text:
                '"Hmm, gue masih doubt sih. Gue akan monitor behavior lo going forward."',
            emoji: '👀',
            isCorrect: false,
            feedback:
                'Threatening tone bisa damage relationship yang tadi sudah membaik.',
            reason:
                'Trust but verify is good, but threatening tone akan undo progress yang sudah dibuat. Better positive reinforcement.',
          ),
        ],
      ),
      ScenarioStep(
        story:
            'Beberapa minggu kemudian, workplace culture jadi lebih inclusive. Alex bahkan jadi advocate untuk diversity. Teman-teman appreciate courage kamu untuk speak up constructively.',
        characterEmoji: '🌟',
        characterAlignment: Alignment.center,
      ),
    ];
  }

  void _loadHousingScenario() {
    scenarioSteps = [
      ScenarioStep(
        story:
            'Setelah 8 bulan ngekos, kamu memutuskan untuk cari tempat tinggal yang lebih proper. Budget limited tapi pengen tempat yang aman dan strategis. Time to hunt!',
        characterEmoji: '🏠',
        characterAlignment: Alignment.center,
      ),
      ScenarioStep(
        story:
            'Kamu browsing online dan nemu 3 option menarik. Semuanya dalam budget, tapi harus pilih yang paling strategic untuk long-term.',
        characterEmoji: '💻',
        characterAlignment: Alignment.center,
      ),
      ScenarioStep(
        story:
            'Option 1: Apartment mewah, dekat mall, tapi 1.5 jam ke kantor. Option 2: Kos sederhana, 30 menit ke kantor, lingkungan aman. Option 3: Apartment murah, 45 menit ke kantor, tapi lingkungan kurang aman.',
        characterEmoji: '🗺️',
        characterAlignment: Alignment.center,
        choices: [
          ScenarioChoice(
            text: 'Pilih apartment mewah, lifestyle is important!',
            emoji: '✨',
            isCorrect: false,
            feedback:
                '3 jam commute daily akan drain energy dan uang transport. Lifestyle expensive dengan hidden cost!',
            reason:
                'Location is everything! Commute time adalah hidden cost yang mahal. 15 jam per week di perjalanan itu tidak sustainable.',
          ),
          ScenarioChoice(
            text: 'Pilih kos sederhana yang dekat kantor dan aman',
            emoji: '🎯',
            isCorrect: true,
            feedback:
                'Smart choice! Proximity ke kantor dan safety adalah priority utama untuk productivity dan peace of mind.',
            reason:
                'Perfect prioritization! Dekat kantor = more time & energy, safe environment = peace of mind. Luxury bisa dikejar nanti.',
          ),
          ScenarioChoice(
            text: 'Pilih apartment murah, lumayan fancy dan not too far',
            emoji: '💸',
            isCorrect: false,
            feedback:
                'Safety is not negotiable! Uang yang disave tidak worth it kalau harus worry soal keamanan.',
            reason:
                'Safety should never be compromised for cost. Stress dari unsafe environment will cost more in mental health.',
          ),
        ],
      ),
      ScenarioStep(
        story:
            'Kamu survey lokasi kos yang dipilih. Owner-nya baik, tapi ada beberapa rules: no tamu setelah 10 malam, bayar listrik terpisah, dan deposit 2 bulan. How do you negotiate?',
        characterEmoji: '🤝',
        characterAlignment: Alignment.centerRight,
        choices: [
          ScenarioChoice(
            text: 'Langsung setuju semua terms tanpa negosiasi',
            emoji: '👍',
            isCorrect: false,
            feedback:
                'Terlalu passive! Reasonable negotiation adalah hak tenant. Some terms might be flexible.',
            reason:
                'Always negotiate respectfully! Terms like deposit amount atau utilities arrangement sering bisa di-adjust.',
          ),
          ScenarioChoice(
            text:
                'Negosiasi deposit jadi 1 bulan, tapi setuju dengan rules lainnya',
            emoji: '💰',
            isCorrect: true,
            feedback:
                'Good balance! Kamu respectful dengan rules penting tapi negotiate yang reasonable.',
            reason:
                'Smart negotiation! Rules keamanan di-respect, tapi financial terms yang reasonable untuk di-negotiate.',
          ),
          ScenarioChoice(
            text:
                'Minta semua rules di-relax: no deposit, tamu bebas, listrik include',
            emoji: '🙄',
            isCorrect: false,
            feedback:
                'Too demanding! Owner akan reluctant dan mungkin prefer tenant lain yang lebih reasonable.',
            reason:
                'Excessive demands bisa ruin good opportunity. Owner punya legitimate concerns yang harus di-respect.',
          ),
        ],
      ),
      ScenarioStep(
        story:
            'Negotiation berhasil! Deposit jadi 1 bulan, dan owner malah offer WiFi premium gratis karena appreciate your respectful approach.',
        characterEmoji: '🎉',
        characterAlignment: Alignment.centerRight,
        choices: [
          ScenarioChoice(
            text: 'Langsung ambil tanpa survey sekali lagi',
            emoji: '⚡',
            isCorrect: false,
            feedback:
                'Too hasty! Final check itu penting untuk ensure everything sesuai expectation.',
            reason:
                'Never skip final inspection! Better safe than sorry. Check everything once more before commitment.',
          ),
          ScenarioChoice(
            text:
                'Final inspection dulu, check semua fasilitas dan kondisi kamar',
            emoji: '🔍',
            isCorrect: true,
            feedback:
                'Very wise! Proper due diligence untuk avoid surprises dan ensure everything is as promised.',
            reason:
                'Due diligence is crucial! Check water pressure, electrical outlets, internet speed, noise level, dll.',
          ),
          ScenarioChoice(
            text: 'Minta discount lagi karena sudah deal',
            emoji: '🤑',
            isCorrect: false,
            feedback:
                'Greedy move! Owner sudah generous, pushing more bisa damage good relationship.',
            reason:
                'Don\'t be greedy after getting good deal! Maintain good relationship dengan owner untuk long-term benefit.',
          ),
        ],
      ),
      ScenarioStep(
        story:
            '6 bulan kemudian, kamu happy dengan pilihan ini. Commute cuma 30 menit, uang transport hemat, dan relationship baik dengan owner. Smart decision pays off!',
        characterEmoji: '🏆',
        characterAlignment: Alignment.center,
      ),
    ];
  }

  void _loadDefaultScenario() {
    scenarioSteps = [
      ScenarioStep(
        story:
            'Ini adalah skenario untuk ${widget.scenarioTitle}. Scenario ini sedang dalam development. Stay tuned untuk update selanjutnya!',
        characterEmoji: '🚧',
        characterAlignment: Alignment.center,
      ),
    ];
  }

  void _initializeAnimations() {
    _characterController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _bubbleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    _feedbackCardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _heartController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _reasonDialogController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _retryController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _textTimer?.cancel();
    _characterController.dispose();
    _bubbleController.dispose();
    _floatingController.dispose();
    _feedbackCardController.dispose();
    _heartController.dispose();
    _reasonDialogController.dispose();
    _retryController.dispose();
    super.dispose();
  }

  void _startCurrentStep() {
    setState(() {
      showChoices = false;
      showFeedback = false;
      showReasonDialog = false;
      needsRetry = false;
      selectedChoice = null;
      _userReason = '';
      _aiFeedback = null;
      _isGeneratingFeedback = false;
      incorrectChoices.clear();
    });

    // Reset dan mulai animasi
    _characterController.reset();
    _bubbleController.reset();

    // Animasi karakter masuk
    _characterController.forward();

    // Delay untuk animasi bubble dan typewriter
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _bubbleController.forward();
        _typeWriterEffect(scenarioSteps[currentStepIndex].story);
      }
    });
  }

  void _typeWriterEffect(String text) {
    _textTimer?.cancel();
    int charIndex = 0;
    setState(() {
      currentStoryText = '';
    });

    _textTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (charIndex < text.length) {
        setState(() {
          currentStoryText = text.substring(0, charIndex + 1);
        });
        charIndex++;

        // Haptic feedback setiap beberapa karakter
        if (charIndex % 5 == 0) {
          HapticFeedback.selectionClick();
        }
      } else {
        timer.cancel();

        // Tampilkan choices jika ada
        if (scenarioSteps[currentStepIndex].choices != null) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted) {
              setState(() => showChoices = true);
            }
          });
        } else {
          // Auto lanjut jika tidak ada pilihan
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              _nextStep();
            }
          });
        }
      }
    });
  }

  void _onChoiceSelected(ScenarioChoice choice, int choiceIndex) {
    // Check if game is over
    if (lives == 0) {
      _showGameOverDialog();
      return;
    }

    // Check if this choice was already selected and incorrect
    if (incorrectChoices.contains(choiceIndex)) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Kamu sudah memilih jawaban ini sebelumnya. Pilih yang lain!',
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
      return;
    }

    setState(() {
      showChoices = false;
      selectedChoice = choice;
    });

    // Show reason dialog first
    _showReasonDialog(choice, choiceIndex);
  }

  void _showReasonDialog(ScenarioChoice choice, int choiceIndex) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ScaleTransition(
        scale: CurvedAnimation(
          parent: _reasonDialogController,
          curve: Curves.elasticOut,
        ),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Row(
            children: [
              Text(choice.emoji, style: TextStyle(fontSize: 24.sp)),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Kenapa Pilih Ini?',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Jelaskan alasan kenapa kamu memilih jawaban "${choice.text}"',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey),
              ),
              SizedBox(height: 16.h),
              TextField(
                onChanged: (value) => _userReason = value,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Tulis alasanmu di sini...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() => showChoices = true);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_userReason.trim().isNotEmpty) {
                  Navigator.of(context).pop();
                  _processChoiceWithReason(choice, choiceIndex);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Harap isi alasan terlebih dahulu'),
                      backgroundColor: Colors.orange,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: const Text('Konfirmasi'),
            ),
          ],
        ),
      ),
    );
    _reasonDialogController.forward(from: 0.0);
  }

  void _processChoiceWithReason(ScenarioChoice choice, int choiceIndex) async {
    setState(() {
      showFeedback = true;
      _isGeneratingFeedback = true;
      _aiFeedback = null;
    });

    _feedbackCardController.forward(from: 0.0);

    try {
      final feedback = await _geminiService.generateFeedback(
        scenarioContext: scenarioSteps[currentStepIndex].story,
        userChoice: choice.text,
        userReason: _userReason,
      );

      // ✅ TAMBAHKAN INI - Simpan AI feedback
      if (mounted) {
        setState(() {
          _aiFeedback = feedback;
          _isGeneratingFeedback = false;
        });
      }
    } catch (e) {
      print('Error generating AI feedback: $e');
      // ✅ TAMBAHKAN INI - Fallback jika AI gagal
      if (mounted) {
        setState(() {
          _aiFeedback = "Ai sedang sibuk, coba lagi nanti.";
          _isGeneratingFeedback = false;
        });
      }
    }

    if (!choice.isCorrect) {
      // Add to incorrect choices
      incorrectChoices.add(choiceIndex);

      // Check if all choices have been tried incorrectly
      final choices = scenarioSteps[currentStepIndex].choices!;
      final hasCorrectChoiceLeft = choices.asMap().entries.any(
        (entry) =>
            entry.value.isCorrect && !incorrectChoices.contains(entry.key),
      );

      if (hasCorrectChoiceLeft) {
        // Still has correct choice available, allow retry
        setState(() {
          needsRetry = true;
        });
        HapticFeedback.heavyImpact();
      } else {
        // No correct choice left OR first wrong answer, lose life immediately
        HapticFeedback.heavyImpact();
        setState(() {
          needsRetry = false;
        });
        _loseLife();
      }
    } else {
      // Correct choice
      HapticFeedback.lightImpact();
      setState(() {
        needsRetry = false;
      });
    }
  }

  void _loseLife() {
    if (lives > 0) {
      _heartController.forward().then((_) {
        setState(() => lives--);
        _heartController.reset();

        if (lives == 0) {
          // Game over - save timestamp for 24-hour cooldown
          _saveGameOverTime();
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              _showGameOverDialog();
            }
          });
        }
      });
    }
  }

  void _saveGameOverTime() {
    // In a real app, you would save this to SharedPreferences
    // For now, we'll use a simple timestamp
    final gameOverTime = DateTime.now().millisecondsSinceEpoch;
    // Save to local storage: SharedPreferences.getInstance().then((prefs) => prefs.setInt('game_over_time', gameOverTime));
  }

  bool _canPlayGame() {
    // In a real app, check if 24 hours have passed since game over
    // For demo purposes, always return true
    // final prefs = await SharedPreferences.getInstance();
    // final gameOverTime = prefs.getInt('game_over_time') ?? 0;
    // final now = DateTime.now().millisecondsSinceEpoch;
    // return (now - gameOverTime) >= (24 * 60 * 60 * 1000); // 24 hours in milliseconds
    return true;
  }

  void _nextStep() {
    if (lives == 0) {
      _showGameOverDialog();
      return;
    }

    _feedbackCardController.reverse().whenComplete(() {
      if (currentStepIndex < scenarioSteps.length - 1) {
        setState(() => currentStepIndex++);
        _startCurrentStep();
      } else {
        _showCompletionDialog();
      }
    });
  }

  void _retryChoices() {
    _loseLife();
    if (lives == 0) {
      // Prevent retry if no lives left
      _showGameOverDialog();
      return;
    }

    setState(() {
      showFeedback = false;
      showChoices = true;
      needsRetry = false;
      selectedChoice = null;
      _userReason = '';
      _aiFeedback = null;
      _isGeneratingFeedback = false;
    });
    _feedbackCardController.reset();
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          '💔 Game Over',
          style: TextStyle(
            fontSize: 20.sp,
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.heart_broken, size: 64.w, color: Colors.red),
            SizedBox(height: 16.h),
            Text(
              'Nyawamu habis! 😵',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              'Tapi jangan khawatir, setiap kesalahan adalah pembelajaran berharga.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(Icons.access_time, color: Colors.orange, size: 24.w),
                  SizedBox(height: 8.h),
                  Text(
                    '⏰ Nyawa akan reset dalam 24 jam',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Gunakan waktu ini untuk merefleksi strategi yang lebih baik!',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Kembali ke Menu',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog() async {
    final xpEarned = lives == 3
        ? 100
        : lives == 2
        ? 75
        : 50;

    try {
      print('🔄 Starting scenario completion: ${widget.scenarioTitle}');

      // 🔥 GUNAKAN ProfileService.addExperience (sama seperti artikel)
      await _profileService.addExperience(xpEarned);
      print('✅ Scenario EXP saved via ProfileService: +$xpEarned');

      // 🔥 UPDATE scenario completion list
      final userData = await UserPreferences.getUserData();
      if (userData != null) {
        final completedScenarios = List<String>.from(
          userData['completedScenarios'] ?? [],
        );

        if (!completedScenarios.contains(widget.scenarioTitle)) {
          completedScenarios.add(widget.scenarioTitle);

          final totalScenarios = userData['totalScenariosCompleted'] ?? 0;

          final updatedData = Map<String, dynamic>.from(userData);
          updatedData.addAll({
            'completedScenarios': completedScenarios,
            'totalScenariosCompleted': totalScenarios + 1,
            'lastActivity': DateTime.now().toString(),
            'lastScenarioCompleted': widget.scenarioTitle,
            'lastScenarioCompletionDate': DateTime.now().toString(),
          });

          await UserPreferences.saveUserData(updatedData);
          print('✅ Scenario completion saved to UserPreferences');
        }
      }

      print('🎉 Scenario completion process finished successfully!');
    } catch (e) {
      print('❌ Error saving scenario completion: $e');
      // Continue showing dialog even if save fails
    }

    // Show dialog setelah save
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber.withOpacity(0.8), Colors.amber],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.celebration, color: Colors.white, size: 32.w),
              ),
              SizedBox(height: 12.h),
              Text(
                '🎉 Selamat!',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[700],
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Kamu berhasil menyelesaikan scenario:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Text(
                  '"${widget.scenarioTitle}"',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 16.h),

              // Performance Stats
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.withOpacity(0.1),
                      Colors.green.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite, color: Colors.red, size: 20.w),
                        SizedBox(width: 8.w),
                        Text(
                          'Nyawa tersisa: $lives/3',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.amber.withOpacity(0.8), Colors.amber],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.stars, color: Colors.white, size: 24.w),
                          SizedBox(width: 8.w),
                          Text(
                            '+$xpEarned EXP',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      lives == 3
                          ? 'Perfect! Semua keputusan tepat! 🏆'
                          : lives == 2
                          ? 'Great job! Hampir sempurna! 🥈'
                          : 'Well done! Terus belajar! 🥉',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        color: Colors.green[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Back to menu
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Kembali ke Menu',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5EE),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black54, size: 24.w),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: _buildProgressBar(),
        actions: [_buildLivesDisplay()],
      ),
      body: Stack(
        children: [
          _buildCharacterAndStory(),
          if (showFeedback) _buildFeedbackCard(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = (currentStepIndex + 1) / scenarioSteps.length;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: Colors.black.withOpacity(0.1),
        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
        minHeight: 8.h,
      ),
    );
  }

  Widget _buildLivesDisplay() {
    return Padding(
      padding: EdgeInsets.only(right: 16.w),
      child: Row(
        children: List.generate(3, (index) {
          bool isActive = index < lives;
          bool isAnimating = index == lives && _heartController.isAnimating;

          return AnimatedBuilder(
            animation: _heartController,
            builder: (context, child) {
              double scale = 1.0;

              if (isAnimating) {
                scale = (1.0 - _heartController.value).clamp(0.1, 1.0);
              }

              return Transform.scale(
                scale: scale,
                child: Icon(
                  isActive
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: Colors.redAccent,
                  size: 24.w,
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildCharacterAndStory() {
    final step = scenarioSteps[currentStepIndex];
    return Column(
      children: [
        // Karakter dengan animasi
        Expanded(
          flex: showChoices ? 3 : 4, // Reduce space when choices are shown
          child: AnimatedBuilder(
            animation: _characterController,
            builder: (context, child) {
              return SlideTransition(
                position:
                    Tween<Offset>(
                      begin: Offset(step.characterAlignment.x * 1.5, -0.3),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _characterController,
                        curve: Curves.easeOutBack,
                      ),
                    ),
                child: AnimatedBuilder(
                  animation: _floatingController,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(0, _floatingController.value * 8),
                    child: Container(
                      alignment: step.characterAlignment,
                      child: Container(
                        width: 120.w,
                        height: 120.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700).withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFFD700).withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            step.characterEmoji,
                            style: TextStyle(fontSize: 48.sp),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Speech bubble - Adjusted size when choices are visible
        Expanded(
          flex: showChoices ? 2 : 3, // Reduce space when choices are shown
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: _bubbleController,
                curve: Curves.elasticOut,
              ),
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: showChoices
                      ? 10.h
                      : 20.h, // Reduce margin when choices shown
                ),
                padding: EdgeInsets.all(
                  showChoices ? 16.w : 24.w,
                ), // Reduce padding
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Text(
                    currentStoryText,
                    style: TextStyle(
                      fontSize: showChoices
                          ? 16.sp
                          : 18.sp, // Smaller text when choices shown
                      height: 1.4,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: showChoices
                        ? 4
                        : null, // Limit lines when choices shown
                    overflow: showChoices
                        ? TextOverflow.ellipsis
                        : TextOverflow.visible,
                  ),
                ),
              ),
            ),
          ),
        ),
        // Choices section - Now part of the main column
        if (showChoices) Expanded(flex: 3, child: _buildChoicesInColumn()),
      ],
    );
  }

  Widget _buildChoicesInColumn() {
    final choices = scenarioSteps[currentStepIndex].choices!;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: AnimationLimiter(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header for choices
            Container(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Text(
                'Pilih responsmu:',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
            // Choices list
            Expanded(
              child: ListView.builder(
                itemCount: choices.length,
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: _buildChoiceButton(choices[index], index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoices() {
    final choices = scenarioSteps[currentStepIndex].choices!;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.all(20.w),
        child: AnimationLimiter(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 500),
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(child: widget),
              ),
              children: choices
                  .asMap()
                  .entries
                  .map((entry) => _buildChoiceButton(entry.value, entry.key))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceButton(ScenarioChoice choice, int index) {
    final isDisabled = incorrectChoices.contains(index) || lives == 0;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 8.h),
      child: ElevatedButton(
        onPressed: isDisabled ? null : () => _onChoiceSelected(choice, index),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled ? Colors.grey[300] : Colors.white,
          foregroundColor: isDisabled ? Colors.grey[600] : Colors.black87,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: BorderSide(
              color: isDisabled ? Colors.grey[400]! : Colors.grey[200]!,
            ),
          ),
          elevation: isDisabled ? 1 : 2,
          shadowColor: Colors.black.withOpacity(0.1),
        ),
        child: Row(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: isDisabled
                    ? Colors.grey[400]
                    : const Color(0xFFFFD700).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: Text(
                  isDisabled ? (lives == 0 ? '💀' : '❌') : choice.emoji,
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                choice.text,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  decoration: isDisabled ? TextDecoration.lineThrough : null,
                  height: 1.3,
                  color: lives == 0 ? Colors.grey[500] : null,
                ),
                textAlign: TextAlign.left,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (lives == 0)
              Icon(Icons.lock, color: Colors.grey[400], size: 16.w),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackCard() {
    if (selectedChoice == null) return const SizedBox.shrink();
    final isCorrect = selectedChoice!.isCorrect;

    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: _feedbackCardController,
                    curve: Curves.elasticOut,
                  ),
                ),
            child: Container(
              padding: EdgeInsets.all(24.w),
              margin: EdgeInsets.all(20.w),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              decoration: BoxDecoration(
                color: isCorrect
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFF44336),
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: (isCorrect ? Colors.green : Colors.red).withOpacity(
                      0.3,
                    ),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ... existing header code ...
                    SizedBox(height: 12.h),

                    // User's reasoning
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.psychology_rounded,
                                color: Colors.white70,
                                size: 16.w,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Alasan kamu:',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            _userReason.isNotEmpty
                                ? _userReason
                                : 'Tidak ada alasan yang diberikan',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // ✅ TAMBAHKAN SECTION AI FEEDBACK INI
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.smart_toy_rounded,
                                color: Colors.white,
                                size: 20.w,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Feedback Personal AI Mentor',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),

                          if (_isGeneratingFeedback)
                            Row(
                              children: [
                                SizedBox(
                                  width: 16.w,
                                  height: 16.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(
                                    'AI Mentor sedang menganalisis alasan kamu...',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.white70,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else if (_aiFeedback != null)
                            Text(
                              _aiFeedback!,
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: Colors.white,
                                height: 1.5,
                              ),
                            )
                          else
                            Text(
                              'Memuat feedback personal...',
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: Colors.white70,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Original Learning Insight
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb_rounded,
                                color: Colors.white70,
                                size: 16.w,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Learning Insight:',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            selectedChoice!.reason,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (lives == 0)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Text(
                            'Game Over - Kembali ke Menu',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      )
                    else if (needsRetry)
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _retryChoices,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: Text(
                                'Coba Lagi',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Pilih jawaban yang benar untuk melanjutkan!',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white70,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _nextStep,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Text(
                            'Lanjut',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
