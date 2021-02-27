<template>
  <div class="w-full" @click.stop>
    <div v-if="title" class="flex mb-1 text-xs">
      <span class="font-medium tracking-wider text-gray-600 uppercase" v-text="title" />
      <div class="flex-grow" />
      <span v-if="!required" class="italic text-gray-500">optional</span>
      <span v-if="hint" class="ml-1 italic text-gray-500" v-text="hint" />
    </div>
    <div
      class="flex items-center w-full px-2 py-1 overflow-hidden text-sm bg-white border"
      :class="[
        disabled ? 'text-gray-500 cursor-not-allowed' : 'border-gray-400 cursor-text text-gray-900 hover:border-gray-500 focus-within:border-gray-500 focus-within:shadow-inner',
        customClass
      ]"
    >
      <i v-if="icon" class="flex-shrink-0 mr-2 fal fa-fw" :class="icon" />
      <span v-else-if="pre" class="flex-shrink-0 mr-2 text-xs leading-none text-gray-500 select-none" v-text="pre" />
      <input
        class="flex-grow min-w-0 p-0 text-sm leading-5 bg-white border-0 focus:ring-0 tabular-nums focus:outline-none"
        :type="_type"
        :value="modelValue"
        @input="input"
        @keydown="onKeyDown"
        @blur="$emit('blur')"
        :placeholder="_placeholder"
        v-focus="focus"
        :disabled="disabled"
        :min="min"
        :max="max"
        step="any"
      >
      <span v-if="post || type === 'date'" class="flex-shrink-0 ml-2 text-xs leading-none text-gray-500 select-none" v-text="post || _day" />
    </div>
  </div>
</template>

<script>
  import { focusDirective, formatDate } from '@krknet/fe/helpers'

  export default {
    name: 'Input',
    props: {
      modelValue: { type: [String, Number], required: false },
      customClass: { type: String, required: false },
      icon: { type: String, required: false },
      pre: { type: String, required: false },
      post: { type: String, required: false },
      title: { type: String, required: false },
      placeholder: { type: String, required: false, default: '' },
      type: { type: String, required: false, default: 'text' },
      min: { type: Number, required: false },
      max: { type: Number, required: false },
      required: { type: Boolean, required: false, default: false },
      disabled: { type: Boolean, required: false, default: false },
      focus: { type: Boolean, required: false, default: false },
      hint: { type: String, required: false }
    },
    computed: {
      _type () {
        if (this.type === 'integer') return 'number'
        if (this.type === 'mixed') return 'string'
        if (this.type === 'date') return 'string'
        return this.type
      },
      _placeholder () {
        return this.type === 'password' ? '**************' : this.placeholder
      },
      _day () {
        if (this.type !== 'date') return
        return ['So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'][new Date(this.modelValue).getDay()]
      }
    },
    methods: {
      onKeyDown (event) {
        switch (this.type) {
          case 'integer':
          case 'number':
            if (['ArrowUp', 'ArrowDown'].includes(event.key)) handleNumberSteps(event)
            break
          case 'mixed':
            if (['ArrowUp', 'ArrowDown'].includes(event.key)) handleMixedSteps(event)
            break
          case 'date':
            if (['ArrowUp', 'ArrowDown'].includes(event.key)) handleDateSteps(event)
            break
        }

        if (event.isHandled) this.input(event)
      },
      setFocus () {
        this.$el.querySelector('input').focus()
      },
      input (event) {
        let value = event.target.value

        if (['integer', 'number'].includes(this.type)) {
          if (value === '') return this.$emit('update:modelValue', undefined)

          if (this.type === 'integer') value = Number.isNaN(Number.parseInt(value)) ? this.modelValue : Number.parseInt(value)
          if (this.type === 'number') value = Number.isNaN(Number.parseFloat(value)) ? this.modelValue : Number.parseFloat(value)

          value = Math.max(this.min === undefined ? -Infinity : this.min, Math.min(this.max === undefined ? Infinity : this.max, value))
        }

        if (value.toString() !== event.target.value) event.target.value = value
        this.$emit('update:modelValue', value)
      }
    },
    directives: { focus: focusDirective }
  }

  const isMac = navigator.platform === 'MacIntel'

  const handleNumberSteps = event => {
    event.preventDefault()
    const currentValue = Number.isNaN(Number.parseFloat(event.target.value)) ? Number.parseFloat(event.target.getAttribute('min')) || 0 : Number.parseFloat(event.target.value)
    const direction = event.key === 'ArrowUp' ? 1 : -1
    const modifier = (isMac ? event.metaKey : event.ctrlKey) ? 100 : event.shiftKey ? 10 : event.altKey ? 0.1 : 1

    const decimals = Math.max(
      (currentValue.toString().split('.')[1] || '').length,
      event.altKey ? 1 : 0
    )

    const newValue = currentValue + (direction * modifier)
    event.target.value = newValue.toFixed(decimals)
    event.isHandled = true
  }

  const handleMixedSteps = event => {
    event.preventDefault()
    const [prefix, currentValue] = resolveValue(event.target.value || 0)
    const direction = event.key === 'ArrowUp' ? 1 : -1
    const modifier = (isMac ? event.metaKey : event.ctrlKey) ? 100 : event.shiftKey ? 10 : event.altKey ? 0.1 : 1

    const decimals = Math.max(
      (currentValue.toString().split('.')[1] || '').length,
      event.altKey ? 1 : 0
    )

    const newValue = currentValue + (direction * modifier)
    event.target.value = prefix + newValue.toFixed(decimals)
    event.isHandled = true
  }

  const handleDateSteps = event => {
    event.preventDefault()
    const date = event.target.value ? new Date(event.target.value) : new Date()
    const direction = event.key === 'ArrowUp' ? 1 : -1

    if (isMac ? event.metaKey : event.ctrlKey) date.setMonth(date.getMonth() + (1 * direction))
    else if (event.shiftKey) date.setDate(date.getDate() + (7 * direction))
    else date.setDate(date.getDate() + (1 * direction))

    if (date.getDay() === 0) date.setDate(date.getDate() + (1 * direction))

    event.target.value = formatDate(date).slice(0, 10)
    event.isHandled = true
  }

  function resolveValue (value, fallback) {
    if (value.length === 0) return fallback
    if (!Number.isNaN(Number.parseInt(value))) return ['', Number.parseInt(value)]

    for (let i = 1; i < value.length; i++) {
      const prefix = value.slice(0, i)
      const testValue = value.slice(i)
      if (!Number.isNaN(Number.parseInt(testValue))) return [prefix, Number.parseInt(testValue)]
    }

    return ['', fallback]
  }
</script>
