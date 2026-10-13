import { PaperPlaneRight, Sparkle } from '@phosphor-icons/react';
import { t } from '../copy';
import { CHAT } from '../mock-data';
import { color, radius, type } from '../theme';
import { NavBar, TitleAppBar } from './chrome';
import { Chip } from './controls';

export interface AssistantState {
  /** Characters of the question typed into the field so far. */
  typedChars: number;
  /** 0→1 pop of the sent question bubble. */
  sent: number;
  /** Typing dots visible (0→1) and their phase. */
  typing: number;
  dotsPhase: number;
  /** Characters of the answer revealed so far. */
  answerChars: number;
  sendPress?: number;
}

function Bubble({ mine, children, pop }: { mine: boolean; children: React.ReactNode; pop: number }) {
  return (
    <div
      style={{
        alignSelf: mine ? 'flex-end' : 'flex-start',
        maxWidth: '85%',
        padding: '12px 16px',
        borderRadius: 24,
        borderBottomRightRadius: mine ? 4 : 24,
        borderBottomLeftRadius: mine ? 24 : 4,
        background: mine ? color.ink : color.surface,
        color: mine ? '#fff' : color.ink,
        ...type.bodyLarge,
        opacity: pop,
        transform: `scale(${0.85 + pop * 0.15})`,
        transformOrigin: mine ? '100% 100%' : '0% 100%',
      }}
    >
      {children}
    </div>
  );
}

/** F9 Assistant: suggestion chips, Roman Urdu question, an answer with the engine's numbers. */
export function AssistantScreen(s: AssistantState): React.JSX.Element {
  const question = CHAT.question.slice(0, s.typedChars);
  return (
    <div style={{ position: 'absolute', inset: 0, top: 44 }}>
      <TitleAppBar title={t('tabAssistant')} />
      <div style={{ padding: '8px 16px', display: 'flex', flexDirection: 'column', gap: 12 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, ...type.titleMedium }}>
          <Sparkle size={20} weight="fill" color={color.coral} />
          {t('assistantIntroTitle')}
        </div>
        <div style={{ ...type.bodyMedium, color: color.muted }}>{t('assistantIntroBody')}</div>
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8 }}>
          <Chip selected={false}>{t('assistantSuggestBackup')}</Chip>
          <Chip selected={false}>{t('assistantSuggestSolar')}</Chip>
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 12, marginTop: 12 }}>
          {s.sent > 0 ? (
            <Bubble mine pop={s.sent}>
              {CHAT.question}
            </Bubble>
          ) : null}
          {s.typing > 0 && s.answerChars === 0 ? (
            <Bubble mine={false} pop={s.typing}>
              <div style={{ display: 'flex', gap: 5, padding: '6px 2px' }}>
                {[0, 1, 2].map((i) => (
                  <div
                    key={i}
                    style={{
                      width: 8,
                      height: 8,
                      borderRadius: 4,
                      background: color.outline,
                      opacity: 0.35 + 0.65 * Math.max(0, Math.sin(s.dotsPhase - i * 0.9)),
                    }}
                  />
                ))}
              </div>
            </Bubble>
          ) : null}
          {s.answerChars > 0 ? (
            <Bubble mine={false} pop={1}>
              {CHAT.answer.slice(0, s.answerChars)}
            </Bubble>
          ) : null}
        </div>
      </div>

      <div
        style={{
          position: 'absolute',
          left: 16,
          right: 16,
          bottom: 98,
          display: 'flex',
          gap: 8,
          alignItems: 'center',
        }}
      >
        <div
          style={{
            flex: 1,
            height: 52,
            borderRadius: radius.md,
            background: color.surface,
            padding: '0 16px',
            display: 'flex',
            alignItems: 'center',
            ...type.bodyLarge,
            color: question ? color.ink : color.muted,
            whiteSpace: 'nowrap',
            overflow: 'hidden',
          }}
        >
          {s.sent > 0 ? t('assistantInputLabel') : question || t('assistantInputLabel')}
        </div>
        <div
          style={{
            width: 52,
            height: 52,
            borderRadius: '50%',
            background: color.indigoContainer,
            display: 'grid',
            placeItems: 'center',
            transform: `scale(${1 - (s.sendPress ?? 0) * 0.1})`,
          }}
        >
          <PaperPlaneRight size={22} weight="fill" />
        </div>
      </div>
      <NavBar active="tabAssistant" />
    </div>
  );
}
