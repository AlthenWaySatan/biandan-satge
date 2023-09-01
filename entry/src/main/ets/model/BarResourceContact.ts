export default class BarResource {
    iconOn: Resource
    iconOff: Resource
    text: Resource
    id: number

    constructor(
        iconOn: Resource,
        iconOff: Resource,
        text: Resource,
        id: number) {

        this.iconOn = iconOn
        this.iconOff = iconOff
        this.text = text
        this.id = id
    }
}