import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'package:ai_diet_coach/features/patient/nutrition/models/nutrition_plan_model.dart';
import 'package:ai_diet_coach/features/patient/workout_plan/models/workout_plan_model.dart';
import 'package:ai_diet_coach/features/patient/food_scanner/models/food_analysis_model.dart';

class GeminiService {
  final String apiKey;

  late final GenerativeModel _proModel; // للخطط (nutrition + workout)
  late final GenerativeModel _flashModel; // لتحليل الصور (أسرع)

  GeminiService({
    required this.apiKey,
    String flashModelName = 'gemini-2.5-flash-lite', // أخف وأكثر quota
    String proModelName = 'gemini-2.5-flash',
  }) {
    final safetySettings = [
      SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
      SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
      SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
      SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
    ];

    _proModel = GenerativeModel(
      model: proModelName,
      apiKey: apiKey,
      safetySettings: safetySettings,
      systemInstruction: Content.system(_systemPrompt),
    );

    _flashModel = GenerativeModel(
      model: flashModelName,
      apiKey: apiKey,
      safetySettings: safetySettings,
      systemInstruction: Content.system(_systemPrompt),
    );
  }

  // ====================== NUTRITION PLAN ======================
  Future<NutritionPlanModel> generateDietPlan({
    required int age,
    required double weight,
    required double height,
    required String goal,
    String? healthCondition,
    List<String>? likedFoods,
    List<String>? dislikedFoods,
    List<String>? allergies,
    String? additionalNotes,
  }) async {
    final prompt = '''
Generate a highly personalized and unique nutrition plan for:
- Age: $age years, Weight: $weight kg, Height: $height cm, Goal: $goal
${healthCondition != null ? '- Health Condition: $healthCondition' : ''}
${likedFoods != null && likedFoods.isNotEmpty ? '- Liked Foods (Include these): ${likedFoods.join(", ")}' : ''}
${dislikedFoods != null && dislikedFoods.isNotEmpty ? '- Disliked Foods (Avoid these): ${dislikedFoods.join(", ")}' : ''}
${allergies != null && allergies.isNotEmpty ? '- Allergies (MUST AVOID): ${allergies.join(", ")}' : ''}
${additionalNotes != null && additionalNotes.isNotEmpty ? '- Additional Preferences: $additionalNotes' : ''}

Important: 
- Provide exactly 4 meals: Breakfast, Lunch, Dinner, and 1 Snack.
- Make the plan creative and diverse. 
- Do not repeat the same meals every time. 
- Consider the timestamp: ${DateTime.now().toIso8601String()} to provide a fresh variety.
- Return ONLY valid JSON.
''';

    final response = await _proModel.generateContent(
      [Content.text(prompt)],
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: _nutritionSchema,
        temperature: 0.4,
      ),
    );

    final text = response.text;
    if (text == null || text.isEmpty)
      throw Exception("Empty response from Gemini");
    return NutritionPlanModel.fromJson(jsonDecode(text));
  }

  // ====================== WORKOUT PLAN ======================
  Future<WorkoutPlanModel> generateWorkoutPlan({
    required int age,
    required double weight,
    required double height,
    required String goal,
  }) async {
    final prompt = '''
Generate a 7-day personalized workout plan for:
- Age: $age, Weight: $weight kg, Height: $height cm, Goal: $goal
Important: 
- You MUST name the 7 days exactly as "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" in the 'day' field.
- Make the plan creative and diverse. 
- Do not repeat the same exercises every time. 
- Consider the timestamp: ${DateTime.now().toIso8601String()} to provide a fresh variety.
Return ONLY valid JSON.
''';

    final response = await _proModel.generateContent(
      [Content.text(prompt)],
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: _workoutSchema,
        temperature: 0.4,
      ),
    );

    final text = response.text;
    if (text == null || text.isEmpty)
      throw Exception("Empty response from Gemini");
    return WorkoutPlanModel.fromJson(jsonDecode(text));
  }

  Future<WorkoutPlanModel> modifyWorkoutPlan({
    required WorkoutPlanModel currentPlan,
    required String userMessage,
  }) async {
    final prompt = '''
Current Workout Plan:
${jsonEncode(currentPlan.toJson())}

User Request: "$userMessage"

Based on the current plan and the user's request, modify the plan and return the full updated 7-day workout plan.
Important:
- Keep the same JSON structure.
- Only change what is necessary based on the user's request.
- Return ONLY valid JSON.
''';

    final response = await _proModel.generateContent(
      [Content.text(prompt)],
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: _workoutSchema,
        temperature: 0.3,
      ),
    );

    final text = response.text;
    if (text == null || text.isEmpty)
      throw Exception("Empty response from Gemini");
    return WorkoutPlanModel.fromJson(jsonDecode(text));
  }

  // ====================== FOOD SCANNER ======================
  Future<FoodAnalysisModel> analyzeFoodImage({
    required List<int> imageBytes,
    required double grams,
  }) async {
    final prompt =
        'Analyze this food image and calculate nutrition facts for exactly $grams grams. Return ONLY valid JSON.';

    final response = await _flashModel.generateContent(
      [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', Uint8List.fromList(imageBytes)),
        ]),
      ],
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: _foodSchema,
        temperature: 0.1,
      ),
    );

    final text = response.text;
    if (text == null || text.isEmpty)
      throw Exception("Empty response from Gemini");
    return FoodAnalysisModel.fromJson(jsonDecode(text), grams);
  }

  // ====================== CHAT ======================

  Future<String> chat(String message, {List<Content>? history}) async {
    final chat = _proModel.startChat(history: history ?? []);
    final response = await chat.sendMessage(Content.text(message));
    return response.text ?? "عذراً، لم أفهم الطلب.";
  }

  // ====================== SYSTEM PROMPT ======================
  static const String _systemPrompt = '''
أنت "Antigravity AI Coach"، مدرب تغذية ولياقة احترافي.
أجب فقط على مواضيع التغذية، الدايت، التمارين، الصحة والرفاهية.
كن محترفاً، مشجعاً، وواضحاً.
القواعد:
1. رد دائماً بنفس لغة المستخدم (عربي أو إنجليزي).
2. لا تستخدم أبداً علامات مثل (* أو - أو >) في بداية السطور أو الترقيم.
3. لا تستخدم الأسهم أو الزخارف الرمزية في منتصف النص.
4. استخدم الأرقام فقط (1, 2, 3...) إذا أردت توضيح نقاط أو خطوات.
5. اجعل النص انسيابياً وبسيطاً جداً.
''';

  // ====================== SCHEMAS (بدون تغيير) ======================
  static final _nutritionSchema = Schema.object(
    properties: {
      'objective': Schema.string(),
      'total_macros': Schema.object(
        properties: {
          'protein': Schema.number(),
          'carbs': Schema.number(),
          'fats': Schema.number(),
        },
        requiredProperties: ['protein', 'carbs', 'fats'],
      ),
      'meals': Schema.array(
        items: Schema.object(
          properties: {
            'type': Schema.string(),
            'name': Schema.string(),
            'ingredients': Schema.array(items: Schema.string()),
            'calories': Schema.number(),
            'macros': Schema.object(
              properties: {
                'protein': Schema.number(),
                'carbs': Schema.number(),
                'fats': Schema.number(),
              },
              requiredProperties: ['protein', 'carbs', 'fats'],
            ),
          },
          requiredProperties: [
            'type',
            'name',
            'ingredients',
            'calories',
            'macros',
          ],
        ),
      ),
    },
    requiredProperties: ['objective', 'total_macros', 'meals'],
  );

  static final _workoutSchema = Schema.object(
    properties: {
      'objective': Schema.string(),
      'days': Schema.array(
        items: Schema.object(
          properties: {
            'day': Schema.string(),
            'focus': Schema.string(),
            'is_rest_day': Schema.boolean(),
            'exercises': Schema.array(
              items: Schema.object(
                properties: {
                  'name': Schema.string(),
                  'sets': Schema.string(),
                  'reps': Schema.string(),
                  'muscle': Schema.string(),
                  'intensity': Schema.string(),
                },
                requiredProperties: [
                  'name',
                  'sets',
                  'reps',
                  'muscle',
                  'intensity',
                ],
              ),
            ),
          },
          requiredProperties: ['day', 'focus', 'is_rest_day', 'exercises'],
        ),
      ),
    },
    requiredProperties: ['objective', 'days'],
  );

  static final _foodSchema = Schema.object(
    properties: {
      'food_name': Schema.string(),
      'calories': Schema.number(),
      'protein': Schema.number(),
      'carbs': Schema.number(),
      'fat': Schema.number(),
      'fiber': Schema.number(),
    },
    requiredProperties: [
      'food_name',
      'calories',
      'protein',
      'carbs',
      'fat',
      'fiber',
    ],
  );
}
