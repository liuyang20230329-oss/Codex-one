const LOCAL_AUDIO_BASE_URL = 'http://192.168.31.181:8123';

const CATEGORY_LIST = [
  {
    id: 'english',
    name: '英语跟读',
    subtitle: '从单词到整句，跟着声音大胆开口。',
    badge: '今日推荐',
    icon: '/assets/animals/english-parrot.svg',
    heroTitle: '今天和晨光老师说英语',
    heroText: '用短句子、慢节奏和跟读提示，帮助孩子自然开口。',
    tone: 'sky',
    stats: '2 节演示 + 8 个本地童谣'
  },
  {
    id: 'songs',
    name: '儿歌乐园',
    subtitle: '边唱边学，记忆会像跳舞一样轻松。',
    badge: '轻松学',
    icon: '/assets/animals/songs-chick.svg',
    heroTitle: '跟着节奏唱一唱',
    heroText: '把洗手、颜色、数字这些日常知识装进旋律里。',
    tone: 'sun',
    stats: '12 首陪伴儿歌'
  },
  {
    id: 'poems',
    name: '诗词花园',
    subtitle: '把经典古诗变成孩子听得懂、记得住的小花园。',
    badge: '国风',
    icon: '/assets/animals/poems-rabbit.svg',
    heroTitle: '在月光和春风里读诗',
    heroText: '每一首诗都分句展示，还会附上温柔的小解释。',
    tone: 'moon',
    stats: '2 节演示 + 4 个本地诗词素材'
  },
  {
    id: 'stories',
    name: '探索故事馆',
    subtitle: '去认识发明家、历史人物和有趣的科学故事。',
    badge: '新奇',
    icon: '/assets/animals/stories-fox.svg',
    heroTitle: '乘着时光列车听故事',
    heroText: '科技、历史和生活常识，都能在这里变成有画面的故事。',
    tone: 'mint',
    stats: '18 个科普故事'
  }
];

const LESSON_LIST = [
  {
    id: 'english-morning-sun',
    categoryId: 'english',
    title: 'Good Morning, Sun',
    subtitle: '晨间问候启蒙',
    summary: '跟着小太阳一起学会 4 句最常用的晨安英语。',
    duration: '约 5 分钟',
    ageRange: '4-6 岁',
    difficulty: '启蒙',
    reward: 18,
    coverLabel: '晨光跟读',
    mentor: '晨光老师',
    focusPoints: ['认识 morning 和 sun', '练习问候语语调', '模仿完整句子'],
    segments: [
      {
        cue: '跟读 01',
        text: 'Good morning, sun.',
        translation: '早安，小太阳。',
        tip: '先跟着节奏读，再把 morning 的尾音拉长一点。'
      },
      {
        cue: '跟读 02',
        text: 'Good morning, my friends.',
        translation: '早安，我的朋友们。',
        tip: '读 friends 时嘴角微笑，会更像打招呼。'
      },
      {
        cue: '跟读 03',
        text: 'Let us smile and start the day.',
        translation: '让我们带着微笑开始新的一天。',
        tip: '一句话有点长，可以先分成 smile 和 start the day 两段。'
      },
      {
        cue: '跟读 04',
        text: 'I am ready to learn and play.',
        translation: '我准备好学习和玩耍啦。',
        tip: '把 ready 读得轻快一点，像真的准备出发。'
      }
    ]
  },
  {
    id: 'english-animal-parade',
    categoryId: 'english',
    title: 'Animal Parade',
    subtitle: '动物英语开口秀',
    summary: '和小动物排队出场，边看边读 elephant、rabbit、bird。',
    duration: '约 6 分钟',
    ageRange: '5-7 岁',
    difficulty: '基础',
    reward: 22,
    coverLabel: '动物派对',
    mentor: '乐乐老师',
    focusPoints: ['动物词汇记忆', '形容动作的短句', '模仿自信语气'],
    segments: [
      {
        cue: '跟读 01',
        text: 'The rabbit hops so fast.',
        translation: '小兔子跳得真快。',
        tip: 'hops 读短一些，像兔子轻轻跳一下。'
      },
      {
        cue: '跟读 02',
        text: 'The bird sings in the tree.',
        translation: '小鸟在树上唱歌。',
        tip: 'sings 和 tree 都要读得轻轻的，像在听鸟叫。'
      },
      {
        cue: '跟读 03',
        text: 'The elephant walks with me.',
        translation: '大象和我一起散步。',
        tip: 'elephant 分成 e-le-phant，更好模仿。'
      },
      {
        cue: '跟读 04',
        text: 'We wave hello in the parade.',
        translation: '我们在游行里挥手说你好。',
        tip: 'wave hello 可以边做动作边读，更容易记住。'
      }
    ]
  },
  {
    id: 'song-wash-hands',
    categoryId: 'songs',
    title: '洗手小歌',
    subtitle: '生活习惯儿歌',
    summary: '把洗手步骤编成简单节奏，孩子边唱边记住好习惯。',
    duration: '约 4 分钟',
    ageRange: '3-6 岁',
    difficulty: '轻松',
    reward: 16,
    coverLabel: '节奏练习',
    mentor: '叮当老师',
    focusPoints: ['生活习惯培养', '节奏模仿', '动作配合记忆'],
    segments: [
      {
        cue: '歌词 01',
        text: '小手打开水花花，手心手背搓一搓。',
        translation: '先用清水打湿，再把手心手背都洗到。',
        tip: '可以跟着歌词做动作，孩子会更投入。'
      },
      {
        cue: '歌词 02',
        text: '手指缝里转个圈，泡泡跳起圆舞曲。',
        translation: '别忘了洗手指缝，泡泡会把细菌带走。',
        tip: '唱到转个圈时一起转手腕，画面感会更强。'
      },
      {
        cue: '歌词 03',
        text: '冲一冲呀甩一甩，小手干净笑开怀。',
        translation: '最后冲净、擦干，完成洗手仪式。',
        tip: '最后一句可以唱得更开心一点，像收尾欢呼。'
      }
    ]
  },
  {
    id: 'song-rainbow-jump',
    categoryId: 'songs',
    title: '彩虹跳跳歌',
    subtitle: '颜色与动作启蒙',
    summary: '一边认颜色，一边跟着节拍跳跃和伸手。',
    duration: '约 5 分钟',
    ageRange: '4-7 岁',
    difficulty: '轻松',
    reward: 17,
    coverLabel: '颜色节奏',
    mentor: '小苗老师',
    focusPoints: ['颜色识别', '身体律动', '重复记忆'],
    segments: [
      {
        cue: '歌词 01',
        text: '红色跳一下，像太阳笑哈哈。',
        translation: '红色像热热的小太阳，跳起来更有力量。',
        tip: '红色可以配合双脚跳，让孩子马上动起来。'
      },
      {
        cue: '歌词 02',
        text: '蓝色挥挥手，像大海轻轻走。',
        translation: '蓝色像大海，动作会更柔和。',
        tip: '唱挥挥手时把手臂打开，营造海浪感觉。'
      },
      {
        cue: '歌词 03',
        text: '彩虹转个圈，快乐留身边。',
        translation: '最后把学到的颜色都串起来，像彩虹一样完整。',
        tip: '收尾可以全家一起转圈，互动感会更好。'
      }
    ]
  },
  {
    id: 'poem-spring-dawn',
    categoryId: 'poems',
    title: '春晓',
    subtitle: '唐诗启蒙',
    summary: '用孩子听得懂的方式感受春天清晨的声音和风景。',
    duration: '约 6 分钟',
    ageRange: '5-8 岁',
    difficulty: '启蒙',
    reward: 20,
    coverLabel: '古诗晨读',
    mentor: '清和老师',
    focusPoints: ['分句朗读古诗', '理解春天画面', '感受押韵节奏'],
    segments: [
      {
        cue: '诗句 01',
        text: '春眠不觉晓，',
        translation: '春天的夜晚睡得香，不知不觉天就亮了。',
        tip: '这一句读得轻轻的，像刚刚睡醒。'
      },
      {
        cue: '诗句 02',
        text: '处处闻啼鸟。',
        translation: '到处都能听见小鸟在唱歌。',
        tip: '闻啼鸟时可以停顿一下，让孩子想象鸟叫声。'
      },
      {
        cue: '诗句 03',
        text: '夜来风雨声，',
        translation: '夜里好像听见了风声和雨声。',
        tip: '这一句可以压低声音，像在回想昨夜。'
      },
      {
        cue: '诗句 04',
        text: '花落知多少。',
        translation: '不知道有多少花瓣被吹落了呢。',
        tip: '结尾拉长一点，像在慢慢看着花瓣飘下。'
      }
    ]
  },
  {
    id: 'poem-quiet-night',
    categoryId: 'poems',
    title: '静夜思',
    subtitle: '月光里的思念',
    summary: '陪孩子在安静的夜里读一首最经典的月夜古诗。',
    duration: '约 5 分钟',
    ageRange: '5-8 岁',
    difficulty: '启蒙',
    reward: 19,
    coverLabel: '月光诗会',
    mentor: '清和老师',
    focusPoints: ['感受诗词情绪', '学习停顿节奏', '理解思乡意象'],
    segments: [
      {
        cue: '诗句 01',
        text: '床前明月光，',
        translation: '床前洒着明亮的月光。',
        tip: '明月光三个字要读得亮一点。'
      },
      {
        cue: '诗句 02',
        text: '疑是地上霜。',
        translation: '看起来像地上铺了一层白白的霜。',
        tip: '疑是可以稍微放慢，让孩子理解“好像”的感觉。'
      },
      {
        cue: '诗句 03',
        text: '举头望明月，',
        translation: '抬起头来看天上的月亮。',
        tip: '读举头时可以真的抬头，动作会帮助记忆。'
      },
      {
        cue: '诗句 04',
        text: '低头思故乡。',
        translation: '低下头来想念远方的家乡。',
        tip: '结尾语气柔和一点，更能读出思念。'
      }
    ]
  },
  {
    id: 'story-light-bulb',
    categoryId: 'stories',
    title: '灯泡是怎样亮起来的',
    subtitle: '科技故事',
    summary: '从爱迪生的坚持出发，讲给孩子听“发明”是什么。',
    duration: '约 7 分钟',
    ageRange: '6-9 岁',
    difficulty: '进阶',
    reward: 24,
    coverLabel: '科学故事',
    mentor: '星河老师',
    focusPoints: ['认识发明家的尝试', '理解失败与坚持', '建立科学好奇心'],
    segments: [
      {
        cue: '故事 01',
        text: '很久以前，夜晚一黑下来，人们只能点蜡烛照明。',
        translation: '故事从“为什么我们需要更亮的光”开始。',
        tip: '先让孩子想象没有电灯的夜晚，会更有代入感。'
      },
      {
        cue: '故事 02',
        text: '爱迪生一次次试验灯丝材料，希望灯泡能亮得更久。',
        translation: '发明不是一下成功，而是不断尝试。',
        tip: '这里可以暂停问孩子：如果是你，会试什么材料？'
      },
      {
        cue: '故事 03',
        text: '终于，稳定又耐用的灯泡出现了，城市的夜晚变得明亮。',
        translation: '坚持和观察，让发明改变了很多人的生活。',
        tip: '结尾可以引导孩子说说电灯给生活带来的便利。'
      }
    ]
  },
  {
    id: 'story-compass-trip',
    categoryId: 'stories',
    title: '指南针带来的旅行魔法',
    subtitle: '历史与发明故事',
    summary: '跟着古代航海者一起出发，认识指南针如何帮助辨别方向。',
    duration: '约 7 分钟',
    ageRange: '6-9 岁',
    difficulty: '进阶',
    reward: 23,
    coverLabel: '历史故事',
    mentor: '星河老师',
    focusPoints: ['认识方向概念', '了解古代发明', '建立历史想象力'],
    segments: [
      {
        cue: '故事 01',
        text: '从前的人出远门，要看太阳、看星星，还要记路上的山和河。',
        translation: '古代旅行并不像现在这样容易。',
        tip: '可以顺手问孩子：如果没有地图，你会怎么找路？'
      },
      {
        cue: '故事 02',
        text: '后来，人们发现磁针总会指向固定方向，指南针就慢慢诞生了。',
        translation: '这让辨别方向变得更可靠。',
        tip: '这里可以配合手势解释东南西北，会更直观。'
      },
      {
        cue: '故事 03',
        text: '有了指南针，航海者能更安心地穿过大海，去认识更远的世界。',
        translation: '一个小小发明，让更多人有机会去探索。',
        tip: '结尾可以延伸到“你最想去哪里探险”。'
      }
    ]
  },
  {
    id: 'english-rhyme-baa-baa-black-sheep',
    categoryId: 'english',
    title: 'Baa Baa Black Sheep',
    subtitle: '本地英语童谣',
    summary: '已从 MP3/儿歌/英语童谣 目录接入，适合做英语磨耳朵和节奏跟读。',
    duration: '本地 MP3',
    ageRange: '3-8 岁',
    difficulty: '跟读素材',
    reward: 12,
    coverLabel: '英语童谣',
    mentor: 'Storynory',
    audioUrl: LOCAL_AUDIO_BASE_URL + '/english/baa-baa-black-sheep.mp3',
    sourcePath: '/MP3/儿歌/英语童谣/Baa Baa Black Sheep - Storynory.mp3',
    fileName: 'Baa Baa Black Sheep - Storynory.mp3',
    focusPoints: ['英语童谣磨耳朵', '模仿节奏和发音', '后续可补歌词字幕'],
    segments: [
      {
        cue: '本地素材',
        text: 'Baa Baa Black Sheep',
        translation: '这首英语童谣已经归类到英语跟读中。',
        tip: '下一步可以继续补歌词、逐句字幕和跟读评分。'
      }
    ]
  },
  {
    id: 'english-rhyme-five-little-monkeys',
    categoryId: 'english',
    title: 'Five Little Monkeys',
    subtitle: '本地英语童谣',
    summary: '已从 MP3/儿歌/英语童谣 目录接入，适合做英语节奏启蒙。',
    duration: '本地 MP3',
    ageRange: '3-8 岁',
    difficulty: '跟读素材',
    reward: 12,
    coverLabel: '英语童谣',
    mentor: 'Storynory',
    audioUrl: LOCAL_AUDIO_BASE_URL + '/english/five-little-monkeys.mp3',
    sourcePath: '/MP3/儿歌/英语童谣/Five Little Monkeys - Storynory.mp3',
    fileName: 'Five Little Monkeys - Storynory.mp3',
    focusPoints: ['数字与节奏启蒙', '英语语感输入', '后续可补歌词字幕'],
    segments: [
      {
        cue: '本地素材',
        text: 'Five Little Monkeys',
        translation: '这首英语童谣已经归类到英语跟读中。',
        tip: '可以继续补逐句歌词，做成适合孩子点读的版本。'
      }
    ]
  },
  {
    id: 'english-rhyme-little-miss-muffet',
    categoryId: 'english',
    title: 'Little Miss Muffet',
    subtitle: '本地英语童谣',
    summary: '已从 MP3/儿歌/英语童谣 目录接入，可作为英语童谣听力素材。',
    duration: '本地 MP3',
    ageRange: '4-8 岁',
    difficulty: '跟读素材',
    reward: 12,
    coverLabel: '英语童谣',
    mentor: 'Storynory',
    audioUrl: LOCAL_AUDIO_BASE_URL + '/english/little-miss-muffet.mp3',
    sourcePath: '/MP3/儿歌/英语童谣/Little Miss Muffet - Storynory.mp3',
    fileName: 'Little Miss Muffet - Storynory.mp3',
    focusPoints: ['童谣语感输入', '节奏模仿', '后续可补逐句跟读'],
    segments: [
      {
        cue: '本地素材',
        text: 'Little Miss Muffet',
        translation: '这首英语童谣已经归类到英语跟读中。',
        tip: '如果后面补充图文和歌词，会更适合小朋友边听边读。'
      }
    ]
  },
  {
    id: 'english-rhyme-mary-had-a-little-lamb',
    categoryId: 'english',
    title: 'Mary Had A Little Lamb',
    subtitle: '本地英语童谣',
    summary: '已从 MP3/儿歌/英语童谣 目录接入，适合做经典童谣启蒙。',
    duration: '本地 MP3',
    ageRange: '3-8 岁',
    difficulty: '跟读素材',
    reward: 12,
    coverLabel: '英语童谣',
    mentor: 'Storynory',
    audioUrl: LOCAL_AUDIO_BASE_URL + '/english/mary-had-a-little-lamb.mp3',
    sourcePath: '/MP3/儿歌/英语童谣/Mary Had A Little Lamb - Storynory.mp3',
    fileName: 'Mary Had A Little Lamb - Storynory.mp3',
    focusPoints: ['经典童谣磨耳朵', '跟着旋律记短句', '后续可补歌词字幕'],
    segments: [
      {
        cue: '本地素材',
        text: 'Mary Had A Little Lamb',
        translation: '这首英语童谣已经归类到英语跟读中。',
        tip: '后续可以结合羊羔插画，做成更完整的儿童启蒙内容。'
      }
    ]
  },
  {
    id: 'english-rhyme-nursery-rhymes-1',
    categoryId: 'english',
    title: 'Nursery Rhymes 1',
    subtitle: '本地英语童谣合集',
    summary: '已从 MP3/儿歌/英语童谣 目录接入，可作为英语童谣合集素材。',
    duration: '本地 MP3',
    ageRange: '3-8 岁',
    difficulty: '合集素材',
    reward: 14,
    coverLabel: '童谣合集',
    mentor: 'Storynory',
    audioUrl: LOCAL_AUDIO_BASE_URL + '/english/nursery-rhymes-1.mp3',
    sourcePath: '/MP3/儿歌/英语童谣/Nursery Rhymes 1 - Storynory.mp3',
    fileName: 'Nursery Rhymes 1 - Storynory.mp3',
    focusPoints: ['合集式听力输入', '适合碎片化陪听', '后续可拆成多个子条目'],
    segments: [
      {
        cue: '本地素材',
        text: 'Nursery Rhymes 1',
        translation: '这组英语童谣合集已经归类到英语跟读中。',
        tip: '后面如果你愿意，我可以把合集继续拆成更细的单首内容。'
      }
    ]
  },
  {
    id: 'english-rhyme-nursery-rhymes-2',
    categoryId: 'english',
    title: 'Nursery Rhymes 2',
    subtitle: '本地英语童谣合集',
    summary: '已从 MP3/儿歌/英语童谣 目录接入，可继续作为英语童谣合集素材。',
    duration: '本地 MP3',
    ageRange: '3-8 岁',
    difficulty: '合集素材',
    reward: 14,
    coverLabel: '童谣合集',
    mentor: 'Storynory',
    audioUrl: LOCAL_AUDIO_BASE_URL + '/english/nursery-rhymes-2.mp3',
    sourcePath: '/MP3/儿歌/英语童谣/Nursery Rhymes 2 - Storynory.mp3',
    fileName: 'Nursery Rhymes 2 - Storynory.mp3',
    focusPoints: ['合集式听力输入', '适合陪听', '后续可继续细拆'],
    segments: [
      {
        cue: '本地素材',
        text: 'Nursery Rhymes 2',
        translation: '这组英语童谣合集已经归类到英语跟读中。',
        tip: '后面也可以拆成单曲，做成更适合孩子点击的课程卡片。'
      }
    ]
  },
  {
    id: 'english-rhyme-twinkle-twinkle-little-star',
    categoryId: 'english',
    title: 'Twinkle Twinkle Little Star',
    subtitle: '本地英语童谣',
    summary: '已从 MP3/儿歌/英语童谣 目录接入，是很适合做跟唱跟读的经典英文儿歌。',
    duration: '本地 MP3',
    ageRange: '3-8 岁',
    difficulty: '跟读素材',
    reward: 13,
    coverLabel: '英语童谣',
    mentor: 'Storynory',
    audioUrl: LOCAL_AUDIO_BASE_URL + '/english/twinkle-twinkle-little-star.mp3',
    sourcePath: '/MP3/儿歌/英语童谣/Twinkle Twinkle Little Star - Storynory.mp3',
    fileName: 'Twinkle Twinkle Little Star - Storynory.mp3',
    focusPoints: ['经典英文儿歌', '旋律跟唱', '后续可补字幕高亮'],
    segments: [
      {
        cue: '本地素材',
        text: 'Twinkle Twinkle Little Star',
        translation: '这首英语童谣已经归类到英语跟读中。',
        tip: '这首特别适合后面做“边唱边亮字”的儿童跟读效果。'
      }
    ]
  },
  {
    id: 'english-rhyme-twinkle-twinkle-little-star-song',
    categoryId: 'english',
    title: 'Twinkle Twinkle Little Star Song',
    subtitle: '本地英语童谣',
    summary: '已从 MP3/儿歌/英语童谣 目录接入，可和同主题素材一起整理成系列内容。',
    duration: '本地 MP3',
    ageRange: '3-8 岁',
    difficulty: '跟读素材',
    reward: 13,
    coverLabel: '英语童谣',
    mentor: 'Storynory',
    audioUrl: LOCAL_AUDIO_BASE_URL + '/english/twinkle-twinkle-little-star-song.mp3',
    sourcePath: '/MP3/儿歌/英语童谣/Twinkle Twinkle Little Star Song - Storynory.mp3',
    fileName: 'Twinkle Twinkle Little Star Song - Storynory.mp3',
    focusPoints: ['同主题童谣扩展', '跟唱节奏训练', '后续可做系列编排'],
    segments: [
      {
        cue: '本地素材',
        text: 'Twinkle Twinkle Little Star Song',
        translation: '这首英语童谣已经归类到英语跟读中。',
        tip: '后面我也可以帮你把星星主题做成连续学习的小专题。'
      }
    ]
  },
  {
    id: 'poem-yue-xia-du-zhuo',
    categoryId: 'poems',
    title: '月下独酌',
    subtitle: '本地诗词朗读',
    summary: '已从 MP3/诗词/单篇朗读 目录接入，适合放进诗词花园中的单篇听读。',
    duration: '本地 M4B',
    ageRange: '5-10 岁',
    difficulty: '诗词素材',
    reward: 15,
    coverLabel: '单篇朗读',
    mentor: 'LibriVox',
    audioUrl: LOCAL_AUDIO_BASE_URL + '/poems/yue-xia-du-zhuo.m4a',
    sourcePath: '/MP3/诗词/单篇朗读/月下独酌 - LibriVox.m4b',
    fileName: '月下独酌 - LibriVox.m4b',
    focusPoints: ['古诗听读启蒙', '单篇素材归类', '后续可补诗句拆分'],
    segments: [
      {
        cue: '本地素材',
        text: '月下独酌',
        translation: '这篇诗词朗读已经归类到诗词花园中。',
        tip: '下一步可以继续补原文、注释和逐句朗读按钮。'
      }
    ]
  },
  {
    id: 'poem-tangshi-300-vol-1',
    categoryId: 'poems',
    title: '唐诗三百首 卷一',
    subtitle: '本地诗词合集',
    summary: '已从 MP3/诗词/唐诗三百首 目录接入，可作为诗词花园中的合集入口。',
    duration: '本地 M4B',
    ageRange: '5-10 岁',
    difficulty: '合集素材',
    reward: 18,
    coverLabel: '唐诗合集',
    mentor: 'LibriVox',
    audioUrl: LOCAL_AUDIO_BASE_URL + '/poems/tangshi-300-vol-1.m4a',
    sourcePath: '/MP3/诗词/唐诗三百首/唐诗三百首 卷一 - LibriVox.m4b',
    fileName: '唐诗三百首 卷一 - LibriVox.m4b',
    focusPoints: ['唐诗合集归类', '适合连续陪听', '后续可拆为单篇课程'],
    segments: [
      {
        cue: '本地素材',
        text: '唐诗三百首 卷一',
        translation: '这组诗词合集已经归类到诗词花园中。',
        tip: '如果你愿意，我后面可以再把卷一里的内容继续拆成单首条目。'
      }
    ]
  },
  {
    id: 'poem-tangshi-300-vol-2',
    categoryId: 'poems',
    title: '唐诗三百首 卷二',
    subtitle: '本地诗词合集',
    summary: '已从 MP3/诗词/唐诗三百首 目录接入，可继续作为诗词合集素材。',
    duration: '本地 M4B',
    ageRange: '5-10 岁',
    difficulty: '合集素材',
    reward: 18,
    coverLabel: '唐诗合集',
    mentor: 'LibriVox',
    audioUrl: LOCAL_AUDIO_BASE_URL + '/poems/tangshi-300-vol-2.m4a',
    sourcePath: '/MP3/诗词/唐诗三百首/唐诗三百首 卷二 - LibriVox.m4b',
    fileName: '唐诗三百首 卷二 - LibriVox.m4b',
    focusPoints: ['诗词合集归类', '适合连续听读', '后续可拆成单篇'],
    segments: [
      {
        cue: '本地素材',
        text: '唐诗三百首 卷二',
        translation: '这组诗词合集已经归类到诗词花园中。',
        tip: '后面也可以继续拆卷做成更适合孩子点开的章节结构。'
      }
    ]
  },
  {
    id: 'poem-tangshi-300-vol-5',
    categoryId: 'poems',
    title: '唐诗三百首 卷五',
    subtitle: '本地诗词合集',
    summary: '已从 MP3/诗词/唐诗三百首 目录接入，已归类进诗词花园。',
    duration: '本地 M4B',
    ageRange: '5-10 岁',
    difficulty: '合集素材',
    reward: 18,
    coverLabel: '唐诗合集',
    mentor: 'LibriVox',
    audioUrl: LOCAL_AUDIO_BASE_URL + '/poems/tangshi-300-vol-5.m4a',
    sourcePath: '/MP3/诗词/唐诗三百首/唐诗三百首 卷五 - LibriVox.m4b',
    fileName: '唐诗三百首 卷五 - LibriVox.m4b',
    focusPoints: ['诗词合集归类', '适合陪听', '后续可继续整理章节'],
    segments: [
      {
        cue: '本地素材',
        text: '唐诗三百首 卷五',
        translation: '这组诗词合集已经归类到诗词花园中。',
        tip: '如果后面内容量继续增加，我也可以帮你做成“卷册 + 单篇”的双层结构。'
      }
    ]
  }
];

const HOME_PLAYLISTS = {
  todayIds: [
    'english-rhyme-twinkle-twinkle-little-star',
    'english-rhyme-baa-baa-black-sheep',
    'poem-yue-xia-du-zhuo'
  ],
  bedtimeIds: [
    'english-rhyme-twinkle-twinkle-little-star-song',
    'poem-tangshi-300-vol-1'
  ]
};

const GROWTH_PANEL = {
  totalStars: 128,
  streakDays: 6,
  totalMinutes: 96,
  weekProgress: [
    { day: '一', value: 3 },
    { day: '二', value: 4 },
    { day: '三', value: 2 },
    { day: '四', value: 5 },
    { day: '五', value: 4 },
    { day: '六', value: 6 },
    { day: '日', value: 3 }
  ],
  missions: [
    {
      id: 'mission-english',
      title: '完成 1 节英语跟读',
      detail: '今天只要跟读 4 句英语，就能得到小星星。',
      reward: '+10 星星',
      done: false
    },
    {
      id: 'mission-poem',
      title: '背诵 1 首古诗',
      detail: '把《春晓》完整听完，再尝试自己读一遍。',
      reward: '+12 星星',
      done: true
    },
    {
      id: 'mission-story',
      title: '听完 1 个探索故事',
      detail: '睡前来听一段科技或历史小故事。',
      reward: '+15 星星',
      done: false
    }
  ],
  badges: [
    {
      id: 'badge-reader',
      name: '晨读小达人',
      description: '连续 5 天完成晨间学习。',
      unlocked: true
    },
    {
      id: 'badge-singer',
      name: '节奏小歌手',
      description: '完成 3 首儿歌跟唱。',
      unlocked: true
    },
    {
      id: 'badge-explorer',
      name: '故事探索员',
      description: '完成 5 次故事馆学习。',
      unlocked: false
    }
  ]
};

const PARENT_PANEL = {
  observations: [
    {
      title: '本周最爱内容',
      value: '英语跟读',
      note: '孩子本周重复打开 4 次，最喜欢早安主题。'
    },
    {
      title: '专注最佳时段',
      value: '19:00 - 19:30',
      note: '晚饭后进入学习状态更稳定，适合安排故事和古诗。'
    },
    {
      title: '最近进步',
      value: '敢开口了',
      note: '跟读时会主动模仿整句，节奏比上周更自然。'
    }
  ],
  schedules: [
    {
      name: '晨间 10 分钟',
      theme: '上学前',
      items: ['英语跟读 1 节', '儿歌热身 1 首']
    },
    {
      name: '睡前 12 分钟',
      theme: '入睡前',
      items: ['古诗 1 首', '故事馆 1 个']
    }
  ],
  tips: [
    '先听再读，让孩子先熟悉声音节奏，再尝试开口。',
    '每次学习控制在 10 到 15 分钟，效果通常更稳定。',
    '如果孩子某一类内容明显更喜欢，可以先从“喜欢”开始建立成就感。'
  ],
  todo: [
    '补充小程序 Logo 和启动页插画',
    '确认首批正式上线内容清单',
    '开通云开发环境并接入学习记录'
  ]
};

function getCategoryById(categoryId) {
  return CATEGORY_LIST.find(function (item) {
    return item.id === categoryId;
  });
}

function getLessonById(lessonId) {
  return LESSON_LIST.find(function (item) {
    return item.id === lessonId;
  });
}

function getLessonsByCategory(categoryId) {
  return LESSON_LIST.filter(function (item) {
    return item.categoryId === categoryId;
  });
}

function getLessonsByIds(ids) {
  return ids
    .map(function (lessonId) {
      return getLessonById(lessonId);
    })
    .filter(Boolean);
}

function getContinueLesson() {
  return getLessonById('english-rhyme-twinkle-twinkle-little-star');
}

function getRecommendedLessonsFor(lessonId) {
  const currentLesson = getLessonById(lessonId);

  if (!currentLesson) {
    return [];
  }

  return LESSON_LIST.filter(function (item) {
    return item.categoryId === currentLesson.categoryId && item.id !== lessonId;
  }).slice(0, 2);
}

module.exports = {
  CATEGORY_LIST: CATEGORY_LIST,
  LESSON_LIST: LESSON_LIST,
  HOME_PLAYLISTS: HOME_PLAYLISTS,
  GROWTH_PANEL: GROWTH_PANEL,
  PARENT_PANEL: PARENT_PANEL,
  getCategoryById: getCategoryById,
  getLessonById: getLessonById,
  getLessonsByCategory: getLessonsByCategory,
  getLessonsByIds: getLessonsByIds,
  getContinueLesson: getContinueLesson,
  getRecommendedLessonsFor: getRecommendedLessonsFor
};
