export default class FolderResource {
    id: number
    icon: Resource
    classify: string
    title: Resource | string
    counter: number

    constructor(
        id: number,
        icon: Resource,
        classify: string,
        title: Resource | string,
        counter: number) {
        this.id = id
        this.icon = icon
        this.classify = classify
        this.title = title
        this.counter = counter
    }
}